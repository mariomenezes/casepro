#!groovy

node {

    try {
        stage 'Checkout'
            checkout scm

        stage 'Test'
            sh 'redis-server &'
            //sh '/var/jenkins_home/run_redis.sh' 
            sh 'virtualenv env -p python3.6'
            sh '. env/bin/activate'
            sh 'env/bin/pip install -r pip-freeze.txt'
            sh 'env/bin/pip install coverage'
            //sh 'cp casepro/settings.py.dev casepro/settings.py'
            //sh "sed -i "s/"HOST": "localhost"/"HOST": "db"/" settings.py"
            sh 'env/bin/coverage run --source="." manage.py test --verbosity=2 --noinput'
            sh 'env/bin/coverage report -m --include="casepro/*" --omit="*/migrations/*,*/tests.py"'
            //Need to restart redis-server for every execution, or it will fail
            sh "$JENKINS_HOME/redis_stop.sh"

        stage 'Build Docker Image with Ansible'
            sh 'pip install docker-py'
            sh 'ansible-playbook  $JENKINS_HOME/$BUILD/build_images.yml -vvv --flush-cache'
            sh 'docker image ls'

        //stage 'Deploy Docker Image with Ansible'
        //    slackSend color: "good", message: "Build successful: `${env.JOB_NAME}#${env.BUILD_NUMBER}` <${env.BUILD_URL}|Open in Jenkins>"
    }

    catch (err) {
        slackSend color: "danger", message: "Build failed :face_with_head_bandage: \n`${env.JOB_NAME}#${env.BUILD_NUMBER}` <${env.BUILD_URL}|Open in Jenkins>"

        throw err
    }

}
