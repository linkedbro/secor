def getAgentTemplate(){
    return '''
    apiVersion: v1
    kind: Pod
    metadata:
      name: jenkins-agent
    spec:
      securityContext:
        runAsUser: 0
        runAsGroup: 0
      containers:
      - name: docker
        image: docker:dind
        securityContext:
          privileged: true
        tty: true
        env:
        - name: DOCKER_TLS_CERTDIR
          value: ""
        - name: DOCKER_OPTS
          value: "--ipv6=false"
        volumeMounts:
        - name: dind-storage
          mountPath: /var/lib/docker
      volumes:
      - name: dind-storage
        emptyDir: {}
    '''
}

pipeline {
    agent none

    environment{
        docker_credential = "docker-access-token-id"
        docker_registry = "https://registry-1.docker.io/v2/"

        docker_repo = "registry-1.docker.io/lbharris/linkedbro"
        image_tag = ""

        helm_base = "secor"
        helm_chart = "secor"

        namespace = "qa"
        service = "secor"
    }

    parameters {
        string(name: 'TARGET_ENV', defaultValue: 'qa', description: 'Target environment')
        string(name: 'HELM_BRANCH', defaultValue: 'dev', description: 'Helm branch')
    }

    stages {
        stage('Build and push docker image') {
            agent {
                kubernetes {
                    yaml getAgentTemplate()
                }
            }
            stages {
                stage("Initial variables"){
                    steps{
                        script{
                            def commit = env.GIT_COMMIT.substring(0, 7)
                            image_tag = "${service}-${params.TARGET_ENV}-${commit}"
                        }
                    }
                }

                stage('build') {
                    steps {
                        dir("."){
                            container('docker') {
                                script {
                                    def dockerOptions = "--ipv6=false"
                                    sleep(10)
                                    docker.image('maven:3.9.6-eclipse-temurin-17-focal').inside('-v $HOME/.m2:/root/.m2 -v $(pwd):/usr/src/secor -w /usr/src/secor') {
                                        sh '_JAVA_OPTIONS=-Djava.net.preferIPv4Stack=true mvn clean package -DskipTests=true'
                                    }
                                    docker.withRegistry(docker_registry, docker_credential) {
                                        sleep(10)
                                        def docker_image = docker.build("${docker_repo}:${image_tag}")
                                        docker_image.push()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        stage('Call deployment process') {
            steps {
                build job: "devops_deploy", wait: true,
                parameters: [
                    [$class: 'StringParameterValue', name: 'HELM_BRANCH', value: "${params.HELM_BRANCH}"],
                    [$class: 'StringParameterValue', name: 'HELM_BASE', value: helm_base],
                    [$class: 'StringParameterValue', name: 'HELM_CHART', value: helm_chart],
                    [$class: 'StringParameterValue', name: 'SERVICE', value: "${service}-${params.TARGET_ENV}"],
                    [$class: 'StringParameterValue', name: 'DOCKER_REPO', value: docker_repo],
                    [$class: 'StringParameterValue', name: 'IMAGE_TAG', value: image_tag],
                    [$class: 'StringParameterValue', name: 'NAMESPACE', value: namespace],
                    [$class: 'BooleanParameterValue', name: 'DRY_RUN', value: 'false'],
                ]
            }
        }
    }

    post {
        success {
            echo 'Pipeline succeeded!'
        }

        failure {
            echo 'Pipeline failed!'
        }
    }
}
