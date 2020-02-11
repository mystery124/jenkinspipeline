#!groovy
import groovy.json.JsonSlurperClassic
node {

    def BUILD_NUMBER=env.BUILD_NUMBER
    def RUN_ARTIFACT_DIR="tests/${BUILD_NUMBER}"
    def SFDC_USERNAME
    def UNIT_TEST_STATUS
    def CODE_PUSH_STATUS

    def USERNAME=env.USERNAME
    def SFDC_HOST = env.SFDC_HOST_DH
    def CONNECTED_APP_CONSUMER_KEY=env.CONNECTED_APP_CONSUMER_KEY_DH

    stage('Checkout Source') {
        checkout scm
    }

	withCredentials([file(credentialsId: JWT_CRED_ID_DH, variable: 'jwt_key_file')]){
        stage('Authorize') {
            rc = sh(returnStatus: true, script: "sfdx force:auth:jwt:grant --clientid ${CONNECTED_APP_CONSUMER_KEY} --jwtkeyfile='${jwt_key_file}' --username ${USERNAME} --instanceurl=${SFDC_HOST}")
            if (rc != 0) {
                error 'Authorize failed'
            }
        }
    }
}