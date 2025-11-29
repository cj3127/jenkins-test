pipeline {
    agent any  
    environment {
        HARBOR_ADDR = "harbor.test.com"
        HARBOR_PROJECT = "library"
        IMAGE_NAME = "nginx"
        IMAGE_TAG = "${BUILD_NUMBER}" 
        FULL_IMAGE_NAME = "${HARBOR_ADDR}/${HARBOR_PROJECT}/${IMAGE_NAME}:${IMAGE_TAG}"
        K8S_NAMESPACE = "default"
    }
    stages {
        stage("拉取代码") {
            steps {
                echo "===== 拉取Git代码 ====="
                git url: "https://github.com/cj3127/jenkins-test.git", branch: "main" 
            }
        }

        stage("构建Docker镜像") {
            steps {
                echo "===== 构建Docker镜像 ====="
                sh "docker build -t ${FULL_IMAGE_NAME} ."
            }
        }

        stage("推送镜像到Harbor") {
            steps {
                echo "===== 推送镜像到Harbor ====="
                withCredentials([usernamePassword(credentialsId: 'harbor-credential', passwordVariable: 'HARBOR_PWD', usernameVariable: 'HARBOR_USER')]) {
                    sh "docker login ${HARBOR_ADDR} -u ${HARBOR_USER} -p ${HARBOR_PWD}"
                    sh "docker push ${FULL_IMAGE_NAME}"
                    sh "docker logout ${HARBOR_ADDR}"
                }
            }
        }

        stage("部署到K8s集群") {
            steps {
                echo "===== 部署到K8s集群 ====="
                sh "sed -i 's|harbor.example.com/library/nginx:latest|${FULL_IMAGE_NAME}|g' k8s/nginx-deployment.yaml"
                sh "kubectl apply -f k8s/nginx-deployment.yaml -n ${K8S_NAMESPACE}"
                sh "kubectl rollout status deployment/nginx-deployment -n ${K8S_NAMESPACE}"
            }
        }

        stage("验证服务") {
            steps {
                echo "===== 验证服务可用性 ====="
                sh "curl -k https://www.test.com -o /dev/null -w '%{http_code}' | grep 200"
            }
        }
    }
    post {
        success {
            echo "===== CI/CD流水线执行成功 ====="
        }
        failure {
            echo "===== CI/CD流水线执行失败 ====="
        }
        always {
            sh "docker rmi ${FULL_IMAGE_NAME} || true"
        }
    }
}
