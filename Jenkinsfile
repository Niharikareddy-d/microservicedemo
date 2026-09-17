pipeline {

    agent any

    options {
        skipDefaultCheckout(true)
        timestamps()
        disableConcurrentBuilds()

        timeout(time: 60, unit: 'MINUTES')

        buildDiscarder(
            logRotator(
                numToKeepStr: '20',
                artifactNumToKeepStr: '10'
            )
        )
    }

    tools {
        jdk 'jdk17'
        maven 'maven'
    }

    environment {

        /* ================================
           Application
           ================================ */

        APP_NAME = 'microservicedemo'

        /* ================================
           AWS
           ================================ */

        AWS_REGION = 'us-east-1'
        AWS_ACCOUNT_ID = '058233700821'

        ECR_REGISTRY =
            '058233700821.dkr.ecr.us-east-1.amazonaws.com'

        EKS_CLUSTER = 'enterprise-test-eks'

        /* ================================
           SonarQube
           ================================ */

        SONAR_PROJECT_KEY = 'microservicedemo'
        SONAR_PROJECT_NAME = 'microservicedemo'

        /* ================================
           Docker
           ================================ */

        IMAGE_TAG = "${BUILD_NUMBER}"

        /* ================================
           Nexus
           ================================ */

        /*
         * Nexus is used as Docker registry.
         *
         * Keep the actual Nexus Docker connector
         * URL configured here after verifying it
         * from the Nexus server.
         */
        NEXUS_REGISTRY = 'YOUR-NEXUS-DOCKER-REGISTRY'

        NEXUS_NAMESPACE = 'microservicedemo'
    }

    stages {

        /* =========================================================
           STAGE 1
           ========================================================= */

        stage('Source Checkout') {

            steps {

                echo '=========================================='
                echo 'Source Checkout'
                echo '=========================================='

                checkout scm

                sh '''
                    set -e

                    echo "Repository:"
                    git remote get-url origin

                    echo "Branch:"
                    git branch --show-current

                    echo "Commit:"
                    git rev-parse HEAD
                '''
            }
        }


        /* =========================================================
           STAGE 2
           ========================================================= */

        stage('Maven Build & Test') {

            steps {

                echo '=========================================='
                echo 'Maven Build & Test'
                echo '=========================================='

                sh '''
                    set -e

                    mvn clean test
                '''
            }
        }


        /* =========================================================
           STAGE 3
           ========================================================= */

        stage('SonarQube Code Analysis') {

            steps {

                echo '=========================================='
                echo 'SonarQube Code Analysis'
                echo '=========================================='

                withSonarQubeEnv('sonar-server') {

                    sh '''
                        set -e

                        mvn \
                          org.sonarsource.scanner.maven:sonar-maven-plugin:sonar \
                          -Dsonar.projectKey="${SONAR_PROJECT_KEY}" \
                          -Dsonar.projectName="${SONAR_PROJECT_NAME}"
                    '''
                }
            }
        }


        /* =========================================================
           STAGE 4
           ========================================================= */

        stage('SonarQube Quality Gate') {

            steps {

                echo '=========================================='
                echo 'SonarQube Quality Gate'
                echo '=========================================='

                timeout(time: 10, unit: 'MINUTES') {

                    waitForQualityGate(
                        abortPipeline: true
                    )
                }
            }
        }


        /* =========================================================
           STAGE 5
           ========================================================= */

        stage('Docker Image Build') {

            steps {

                echo '=========================================='
                echo 'Docker Image Build'
                echo '=========================================='

                sh '''
                    set -e

                    echo "Build Number: ${BUILD_NUMBER}"
                    echo "Image Tag: ${IMAGE_TAG}"

                    services="
                    gateway
                    auth
                    user
                    admin
                    employee
                    customer
                    hr
                    task
                    "

                    for service in $services
                    do
                        echo ""
                        echo "=========================================="
                        echo "Building ${service}"
                        echo "=========================================="

                        docker build \
                          -t ${APP_NAME}-${service}:${IMAGE_TAG} \
                          -f ${service}-service/Dockerfile .
                    done

                    echo ""
                    echo "=========================================="
                    echo "Built Images"
                    echo "=========================================="

                    docker images | grep "${APP_NAME}"
                '''
            }
        }


        /* =========================================================
           STAGE 6
           ========================================================= */

        stage('Trivy Image Security Scan') {

            steps {

                echo '=========================================='
                echo 'Trivy Image Security Scan'
                echo '=========================================='

                sh '''
                    set -e

                    trivy --version

                    rm -rf trivy-reports
                    mkdir -p trivy-reports

                    services="
                    gateway
                    auth
                    user
                    admin
                    employee
                    customer
                    hr
                    task
                    "

                    for service in $services
                    do
                        IMAGE="${APP_NAME}-${service}:${IMAGE_TAG}"

                        echo ""
                        echo "=========================================="
                        echo "Scanning ${IMAGE}"
                        echo "=========================================="

                        trivy image \
                          --severity HIGH,CRITICAL \
                          --format table \
                          -o "trivy-reports/${service}-${IMAGE_TAG}.txt" \
                          "${IMAGE}"
                    done
                '''
            }

            post {

                always {

                    archiveArtifacts(
                        artifacts: 'trivy-reports/*.txt',
                        allowEmptyArchive: true
                    )
                }
            }
        }


        /* =========================================================
           STAGE 7
           ========================================================= */

        stage('Nexus Docker Image Push') {

            steps {

                echo '=========================================='
                echo 'Nexus Docker Image Push'
                echo '=========================================='

                sh '''
                    set -e

                    echo "Nexus Docker registry:"
                    echo "${NEXUS_REGISTRY}"

                    if [ "${NEXUS_REGISTRY}" = "YOUR-NEXUS-DOCKER-REGISTRY" ]; then
                        echo "ERROR: NEXUS_REGISTRY is not configured."
                        exit 1
                    fi

                    echo ""
                    echo "Logging in to Nexus Docker registry..."

                    docker login "${NEXUS_REGISTRY}"

                    /*
                     * The exact four Nexus images must match
                     * the approved project registry mapping.
                     *
                     * Do not push images that are not assigned
                     * to Nexus.
                     */

                    echo ""
                    echo "Nexus authentication successful."
                    echo "Nexus image publication is ready."
                '''
            }
        }


        /* =========================================================
           STAGE 8
           ========================================================= */

        stage('Amazon ECR Authentication') {

            steps {

                echo '=========================================='
                echo 'Amazon ECR Authentication'
                echo '=========================================='

                sh '''
                    set -e

                    aws ecr get-login-password \
                      --region "${AWS_REGION}" \
                    | docker login \
                      --username AWS \
                      --password-stdin \
                      "${ECR_REGISTRY}"

                    echo "ECR authentication successful."
                '''
            }
        }


        /* =========================================================
           STAGE 9
           ========================================================= */

        stage('Amazon ECR Image Push') {

            steps {

                echo '=========================================='
                echo 'Amazon ECR Image Push'
                echo '=========================================='

                sh '''
                    set -e

                    services="
                    gateway
                    auth
                    user
                    admin
                    employee
                    customer
                    hr
                    task
                    "

                    for service in $services
                    do

                        SOURCE_IMAGE="${APP_NAME}-${service}:${IMAGE_TAG}"

                        TARGET_REPOSITORY="terraform-platform-test-${service}-service"

                        TARGET_IMAGE="${ECR_REGISTRY}/${TARGET_REPOSITORY}:${IMAGE_TAG}"

                        echo ""
                        echo "=========================================="
                        echo "Publishing ${service}"
                        echo "=========================================="

                        docker tag \
                          "${SOURCE_IMAGE}" \
                          "${TARGET_IMAGE}"

                        docker push \
                          "${TARGET_IMAGE}"

                    done

                    echo ""
                    echo "=========================================="
                    echo "ECR Images Published"
                    echo "=========================================="

                    docker images | grep "${ECR_REGISTRY}"
                '''
            }
        }


        /* =========================================================
           STAGE 10
           ========================================================= */

        stage('Helm Validation') {

            steps {

                echo '=========================================='
                echo 'Helm Validation'
                echo '=========================================='

                sh '''
                    set -e

                    test -f helm/Chart.yaml
                    test -f helm/values.yaml

                    echo "Helm chart:"
                    ls -la helm

                    echo ""
                    echo "Running Helm lint..."

                    helm lint helm

                    echo ""
                    echo "Rendering Helm templates..."

                    helm template \
                      microservices \
                      helm \
                      > helm-rendered.yaml

                    test -s helm-rendered.yaml

                    echo ""
                    echo "Helm validation successful."
                '''
            }

            post {

                always {

                    archiveArtifacts(
                        artifacts: 'helm-rendered.yaml',
                        allowEmptyArchive: true
                    )
                }
            }
        }


        /* =========================================================
           STAGE 11
           ========================================================= */

        stage('Helm Deployment to EKS') {

            steps {

                echo '=========================================='
                echo 'Helm Deployment to EKS'
                echo '=========================================='

                sh '''
                    set -e

                    echo "Updating kubeconfig..."

                    aws eks update-kubeconfig \
                      --name "${EKS_CLUSTER}" \
                      --region "${AWS_REGION}" \
                      --kubeconfig "${HOME}/.kube/config"

                    export KUBECONFIG="${HOME}/.kube/config"

                    echo ""
                    echo "Verifying EKS access..."

                    kubectl get nodes

                    echo ""
                    echo "Deploying Helm release..."

                    helm upgrade \
                      --install \
                      microservices \
                      helm \
                      --namespace microservices \
                      --create-namespace \
                      --wait \
                      --timeout 10m

                    echo ""
                    echo "Helm deployment completed."
                '''
            }
        }


        /* =========================================================
           STAGE 12
           ========================================================= */

        stage('Deployment Verification') {

            steps {

                echo '=========================================='
                echo 'Deployment Verification'
                echo '=========================================='

                sh '''
                    set -e

                    export KUBECONFIG="${HOME}/.kube/config"

                    echo ""
                    echo "Helm release:"
                    helm list \
                      --namespace microservices

                    echo ""
                    echo "Namespaces:"
                    kubectl get namespaces

                    echo ""
                    echo "Pods:"
                    kubectl get pods \
                      --all-namespaces \
                      -o wide

                    echo ""
                    echo "Services:"
                    kubectl get svc \
                      --all-namespaces

                    echo ""
                    echo "Ingress:"
                    kubectl get ingress \
                      --all-namespaces

                    echo ""
                    echo "Deployment status:"
                    kubectl get deployments \
                      --all-namespaces

                    echo ""
                    echo "Waiting for deployments..."

                    kubectl rollout status \
                      deployment \
                      --all \
                      --all-namespaces \
                      --timeout=10m

                    echo ""
                    echo "=========================================="
                    echo "EKS Deployment Verification Successful"
                    echo "=========================================="
                '''
            }
        }
    }


    post {

        always {

            echo '=========================================='
            echo 'Pipeline Execution Completed'
            echo "Build Number: ${BUILD_NUMBER}"
            echo "Image Tag: ${IMAGE_TAG}"
            echo '=========================================='

            sh '''
                docker image prune -f || true
            '''
        }

        success {

            echo '=========================================='
            echo 'ENTERPRISE CI/CD PIPELINE SUCCESS'
            echo '=========================================='
        }

        failure {

            echo '=========================================='
            echo 'ENTERPRISE CI/CD PIPELINE FAILED'
            echo '=========================================='

            echo 'Review the failed Jenkins stage and console output.'
        }
    }
}
