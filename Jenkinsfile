#!groovy
import groovy.json.JsonSlurperClassic
node {

    def BUILD_NUMBER=env.BUILD_NUMBER
    def RUN_ARTIFACT_DIR="tests/${BUILD_NUMBER}"
    def SFDC_USERNAME
    def UNIT_TEST_STATUS
    def CODE_PUSH_STATUS

    def HUB_ORG=env.HUB_ORG_DH
    def SFDC_HOST = env.SFDC_HOST_DH
    def CONNECTED_APP_CONSUMER_KEY=env.CONNECTED_APP_CONSUMER_KEY_DH

    stage('Checkout Source') {
        checkout scm
    }

    withCredentials([file(credentialsId: JWT_CRED_ID_DH, variable: 'jwt_key_file')]){

        try {
            stage('Create Scratch Org') {
                rc = sh returnStatus: true, script: "sfdx force:auth:jwt:grant --clientid ${CONNECTED_APP_CONSUMER_KEY} --jwtkeyfile '${jwt_key_file}' --username ${HUB_ORG} -a VCEPROD"
                if (rc != 0) { error 'hub org authorization failed' }

                rmsg = sh(returnStdout: true, script: "sfdx force:org:create --definitionfile config/project-scratch-def.json --targetdevhubusername VCEPROD --json")
                printf rmsg
                def jsonSlurper = new JsonSlurperClassic()
                def robj = jsonSlurper.parseText(rmsg)
                if (robj.status != 0) {
                    error 'Create Scratch Org: ' + robj.message
                }
                SFDC_USERNAME=robj.result.username
                robj = null
            }


            stage('Push To Test Org') {
                rc = sh returnStatus: true, script: "sfdx force:source:push -f --targetusername ${SFDC_USERNAME}"
                if (rc != 0) {
                    error 'Push To Test Org failed'
                }
            }

            stage('Run Apex Test') {
                sh "mkdir -p ${RUN_ARTIFACT_DIR}"
                timeout(time: 120, unit: 'SECONDS') {
                    rc = sh returnStatus: true, script: "sfdx force:apex:test:run --testlevel RunLocalTests --outputdir ${RUN_ARTIFACT_DIR} --resultformat tap --targetusername ${SFDC_USERNAME}"
                    UNIT_TEST_STATUS = rc
                }
            }

            stage('Collect Results') {
                junit keepLongStdio: true, testResults: 'tests/**/*-junit.xml'
                if (UNIT_TEST_STATUS != 0) {
                    error 'Run Apex Test failed'
                }
            }
        } finally {
            stage('Delete Test Org') {
                timeout(time: 120, unit: 'SECONDS') {
                    rc = sh returnStatus: true, script: "sfdx force:org:delete --targetusername ${SFDC_USERNAME} --noprompt"
                    if (rc != 0) {
                        error 'org deletion request failed'
                    }
                }
            }
        }
    }
}