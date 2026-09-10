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
                        ).trim()
                            .split('\n')
                            .findAll { it?.trim() }

                    } else {

                        changedFiles = sh(
                            script: 'git ls-files',
                            returnStdout: true
                        ).trim()
                            .split('\n')
                            .findAll { it?.trim() }
                    }

                    /*
                     * Services that currently contain Dockerfiles
                     * and are deployable microservices.
                     */
                    def deployableServices = sh(
                        script: '''
                            find . -mindepth 2 -maxdepth 2 \
                                -type f \
                                -name Dockerfile \
                                -printf '%h\\n' |
                            sed 's#^./##' |
                            sort
                        ''',
                        returnStdout: true
                    ).trim()

                    def services = deployableServices ?
                        deployableServices
                            .split('\n')
                            .findAll { it?.trim() } :
                        []

                    def affectedServices = [] as Set

                    changedFiles.each { file ->

                        def topLevel = file.tokenize('/')[0]

                        /*
                         * Direct microservice change.
                         */
                        if (services.contains(topLevel)) {
                            affectedServices.add(topLevel)
                        }

                        /*
                         * Root Maven POM change.
                         */
                        if (file == 'pom.xml') {
                            affectedServices.addAll(services)
                        }

                        /*
                         * common-library change.
                         *
                         * Every service that declares common-library
                         * as a dependency is affected.
                         */
                        if (file.startsWith('common-library/')) {

                            services.each { service ->

                                def pomFile = "${service}/pom.xml"

                                if (fileExists(pomFile)) {

                                    def usesCommonLibrary = sh(
                                        script: """
                                            grep -q \
                                              '<artifactId>common-library</artifactId>' \
                                              '${pomFile}'
                                        """,
                                        returnStatus: true
                                    ) == 0

                                    if (usesCommonLibrary) {
                                        affectedServices.add(service)
                                    }
                                }
                            }
                        }
                    }

                    env.AFFECTED_SERVICES =
                        affectedServices.toList().sort().join(',')

                    if (affectedServices.isEmpty()) {

                        echo 'No microservice changes detected.'

                    } else {

                        echo 'Affected microservices:'

                        affectedServices
                            .toList()
                            .sort()
                            .each { service ->
                                echo " - ${service}"
                            }
                    }
                }
            }
        }

        stage('Maven Build & Unit Tests') {
            when {
                expression {
                    env.AFFECTED_SERVICES?.trim()
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

        always {
            junit(
                testResults: '**/target/surefire-reports/*.xml',
                allowEmptyResults: true
            )
        }

        success {
            echo 'Application CI completed successfully.'
        }

        failure {
            echo 'Application CI failed.'
        }
    }
}
