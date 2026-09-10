pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
        skipDefaultCheckout(true)
    }

    environment {
        MAVEN_OPTS = '-Dmaven.repo.local=.m2/repository'
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Detect Changes') {
            steps {
                script {

                    def changedFiles = []

                    if (sh(
                        script: 'git rev-parse --verify HEAD~1 >/dev/null 2>&1',
                        returnStatus: true
                    ) == 0) {

                        changedFiles = sh(
                            script: 'git diff --name-only HEAD~1 HEAD',
                            returnStdout: true
                        ).trim().split('\n') as List

                    } else {

                        changedFiles = sh(
                            script: 'git ls-files',
                            returnStdout: true
                        ).trim().split('\n') as List
                    }

                    echo "Changed files:"
                    changedFiles.each {
                        echo " - ${it}"
                    }

                    def deployableServices = sh(
                        script: '''
                            find . -mindepth 2 -maxdepth 2 \
                              -name Dockerfile \
                              -printf '%h\\n' |
                            sed 's#^./##' |
                            sort
                        ''',
                        returnStdout: true
                    ).trim()

                    def services = deployableServices ?
                        deployableServices.split('\n') as List :
                        []

                    def affectedServices = [] as Set

                    changedFiles.each { file ->

                        def topLevel = file.tokenize('/')[0]

                        if (services.contains(topLevel)) {
                            affectedServices.add(topLevel)
                        }

                        if (file == 'pom.xml') {
                            affectedServices.addAll(services)
                        }

                        if (file.startsWith('common-library/')) {

                            services.each { service ->

                                def usesCommonLibrary = sh(
                                    script: """
                                        grep -q '<artifactId>common-library</artifactId>' '${service}/pom.xml'
                                    """,
                                    returnStatus: true
                                ) == 0

                                if (usesCommonLibrary) {
                                    affectedServices.add(service)
                                }
                            }
                        }
                    }

                    if (affectedServices.isEmpty()) {
                        echo 'No deployable microservice changes detected.'
                        env.AFFECTED_SERVICES = ''
                    } else {
                        env.AFFECTED_SERVICES =
                            affectedServices.toList().sort().join(',')

                        echo "Affected services:"
                        affectedServices.toList().sort().each {
                            echo " - ${it}"
                        }
                    }
                }
            }
        }

        stage('Maven Build & Unit Tests') {
            when {
                expression {
                    return env.AFFECTED_SERVICES?.trim()
                }
            }

            steps {
                script {

                    def modules = env.AFFECTED_SERVICES

                    sh """
                        mvn -B -ntp \
                          -pl ${modules} \
                          -am \
                          clean test
                    """
                }
            }
        }
    }

    post {
        success {
            echo 'Application CI completed successfully.'
        }

        failure {
            echo 'Application CI failed.'
        }

        always {
            junit(
                testResults: '**/target/surefire-reports/*.xml',
                allowEmptyResults: true
            )
        }
    }
}
