#!groovy
import groovy.json.JsonSlurperClassic
node {

    def BUILD_NUMBER=env.BUILD_NUMBER
    def RUN_ARTIFACT_DIR="tests/${BUILD_NUMBER}"

    def USERNAME=env.USERNAME
    def SFDC_HOST = env.SFDC_HOST
    def CONSUMER_KEY=env.CONSUMER_KEY
    def ORG_CONFIG_LOCATION=env.ORG_CONFIG_LOCATION
    def TEST_LEVEL=env.TEST_LEVEL

    stage('Checkout Source') {
        checkout scm
    }

	withCredentials([file(credentialsId: SERVER_KEY, variable: 'jwt_key_file')]){
        stage('Authorize') {
            rc = sh(returnStatus: true, script: "sfdx force:auth:jwt:grant --clientid ${CONSUMER_KEY} --jwtkeyfile='${jwt_key_file}' --username ${USERNAME} --instanceurl=${SFDC_HOST}")
            if (rc != 0) {
                error 'Authorize failed'
            }
        }
        stage('Copy Config Files') {
            sh("cp ${ORG_CONFIG_LOCATION} ./ -rf")
        }
        stage('Deploy with unit tests') {
            rmsg = sh(returnStdout: true, script: "sfdx force:source:deploy --testlevel ${TEST_LEVEL} -p ./force-app -u ${USERNAME} -w 200 --json")
        }
    }
}