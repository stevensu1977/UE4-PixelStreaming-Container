#!/usr/bin/env bash
 
 
 #build function
 build() {
	 TAG_NAME=$1
	 if [ "$TAG_NAME" == "" ] ; then
		 TAG_NAME="pixelstreaming-demo" 
         fi
	 echo "TAG_NAME:${TAG_NAME}"
	 docker build -t ${TAG_NAME} .
 }


#stop function
stop(){
          docker-compose $COMPOSE_FLAGS down
}


#ps function
dcps(){
          docker-compose $COMPOSE_FLAGS ps
}


start(){
     # Determine which release of the Unreal Engine we will be running container images for
     UNREAL_ENGINE_RELEASE="4.27"
     if [[ ! -z "$1" ]]; then
             HTTP_PORT="$1"
     else 
             HTTP_PORT=10001
     fi
     
     if [[ ! -z "$2" ]]; then
             TURN_PORT="$2"
     else 
             TURN_PORT=3578
     fi
     
     
     if [[ ! -z "$3" ]]; then
             STREAMER_PORT="$3"
     else 
             STREAMER_PORT=8888
     fi
     
     
     

     # Verify that either curl is available
     if which curl 1>/dev/null; then
             HTTPS_COMMAND="curl -s"
     else 
             echo "Please install curl"
             exit 1
     fi

     # Retrieve the public IP address of the host system
     PUBLIC_IP=$($HTTPS_COMMAND 'http://169.254.169.254/latest/meta-data/public-ipv4')
    

     # Run the Pixel Streaming example
     export UNREAL_ENGINE_RELEASE
     export EXTRA_PEERCONNECTION_OPTIONS
     export PUBLIC_IP
     export TURN_PORT
     export HTTP_PORT
     export STREAMER_PORT
     export PWD=$(pwd)
     docker-compose $COMPOSE_FLAGS up -d --force-recreate 
     echo ""
     echo http://${PUBLIC_IP}:${HTTP_PORT}
     echo ""
 }

#main 
if  [[ $# -lt 1 ]]; then
	     echo "tools.sh build|start|ps|stop"
else
		  if [[ ! -z "$PROJECT_NAME" ]]; then
             COMPOSE_FLAGS="--project-name ${PROJECT_NAME}"
             echo "docker-compose project: ${PROJECT_NAME}"
		  else 
             COMPOSE_FLAGS=""
		  fi
     
		  OPTION=$1
		  case $OPTION in
			  "build")
				  echo "############BUILD############"
				  build ${2}
				  echo "############BUILD SUCCESSFUL############"
				  ;;

			  "start")
				  echo "############START############"
				  start ${2} ${3} ${4}
				  echo "############START SUCCESSFUL############"
				  ;;
				  
			  "ps")
				  echo "############PS############"
				  dcps
				  ;;

			  "stop")
				  echo "############STOP############"
			      stop
			      echo "############STOP SUCCESSFUL############"
				  ;;

			  *)
	              echo "tools.sh build|start|stop"
				  exit 1

			  esac
 fi
