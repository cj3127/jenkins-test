pipeline {
    agent any  # 用Jenkins本机执行（或用K8s Agent）
    environment {
        HARBOR_ADDR = "192.168.121.106"  # Harbor地址
        HARBOR_PROJECT = "library"       # Harbor项目
        IMAGE_NAME = "nginx"             # 镜像名称
        IMAGE_TAG = "${BUILD_NUMBER}"    # 镜像标签（用构建号）
        FULL_IMAGE_NAME = "${HARBOR_ADDR}/${HARBOR_PROJECT}/${IMAGE_NAME}:${IMAGE_TAG}"
        K8S_NAMESPACE = "default"        # K8s部署命名空间
    }
    stages {
        stage("拉取代码") {
            steps {
                echo "===== 拉取Git代码 ====="
                git url: "https://github.com/cj3127/jenkins-test.git", branch: "main"  # 替换为你的Git仓库地址
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
                # 替换Deployment中的镜像标签
                sh "sed -i 's|harbor.example.com/library/nginx:latest|${FULL_IMAGE_NAME}|g' k8s/nginx-deployment.yaml"
                # 应用K8s配置（滚动更新）
                sh "kubectl apply -f k8s/nginx-deployment.yaml -n ${K8S_NAMESPACE}"
                # 验证部署
                sh "kubectl rollout status deployment/nginx-deployment -n ${K8S_NAMESPACE}"
            }
        }

        stage("验证服务") {
            steps {
                echo "===== 验证服务可用性 ====="
                sh "curl -k https://www.test.com -o /dev/null -w '%{http_code}' | grep 200"  # 验证页面返回200
            }
        }
    }
    post {
        success {
            echo "===== CI/CD流水线执行成功 ====="
        }
        failure {
            echo "===== CI/CD流水线执行失败 ====="
            # 可选：发送告警（邮件/钉钉）
        }
        always {
            # 清理本地镜像（可选）
            sh "docker rmi ${FULL_IMAGE_NAME} || true"
        }
    }
}
