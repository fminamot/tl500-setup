#!/bin/bash

source checkvar

cat << EOF > /tmp/allure-auth.yaml
apiVersion: v1
data:
  password: "$(echo -n password | base64 -w0)"
  username: "$(echo -n admin | base64 -w0)"
kind: Secret
metadata:
  name: allure-auth
EOF

oc apply -f /tmp/allure-auth.yaml

# Allureをubiquitous-journey/values-tooling.yamlに追加 

if [[ $(yq e '.applications[] | select(.name=="allure") | length' /projects/tech-exercise/ubiquitous-journey/values-tooling.yaml) < 1 ]]; then
   yq e '.applications += {"name":"allure","enabled":true,"source":"https://github.com/eformat/allure.git","source_path":"chart","source_ref":"main","values":{"security":{"secret":"allure-auth"}}}' -i /projects/tech-exercise/ubiquitous-journey/values-tooling.yaml
fi

# allure-post-reportタスク定義

cd /projects/tech-exercise
cat <<'EOF' > tekton/templates/tasks/allure-post-report.yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: allure-post-report
  labels:
    app.kubernetes.io/version: "0.2"
spec:
  description: >-
    This task used for uploading test reports to allure
  workspaces:
    - name: output
  params:
    - name: APPLICATION_NAME
      type: string
      default: ""
    - name: IMAGE
      description: the image to use to upload results
      type: string
      default: "quay.io/openshift/origin-cli:4.9"
    - name: WORK_DIRECTORY
      description: Directory to start build in (handle multiple branches)
      type: string
    - name: ALLURE_HOST
      description: "Allure Host"
      default: "http://allure:5050"
    - name: ALLURE_SECRET
      type: string
      description: Secret containing Allure credentials
      default: allure-auth
  steps:
    - name: save-tests
      image: $(params.IMAGE)
      workingDir: $(workspaces.output.path)/$(params.WORK_DIRECTORY)
      env:
        - name: ALLURE_USERNAME
          valueFrom:
            secretKeyRef:
              name: $(params.ALLURE_SECRET)
              key: username
        - name: ALLURE_PASSWORD
          valueFrom:
            secretKeyRef:
              name: $(params.ALLURE_SECRET)
              key: password
      script: |
        #!/bin/bash
        curl -sLo send_results.sh https://raw.githubusercontent.com/eformat/allure/main/scripts/send_results.sh && chmod 755 send_results.sh
        ./send_results.sh $(params.APPLICATION_NAME) \
          $(workspaces.output.path)/$(params.WORK_DIRECTORY) \
          ${ALLURE_USERNAME} \
          ${ALLURE_PASSWORD} \
          $(params.ALLURE_HOST)
EOF

cd /projects/tech-exercise
git add ubiquitous-journey/values-tooling.yaml tekton/templates/tasks/allure-post-report.yaml
git commit -m  "ADD - Allure tooling"
git push

sleep 30

# Allureがデプロイされまで待つ
oc rollout status deployment allure -n ${TEAM_NAME}-ci-cd --timeout 120s

# Allure UI
echo "Allure UI=https://$(oc get route allure --template='{{ .spec.host }}' -n ${TEAM_NAME}-ci-cd)/allure-docker-service/projects/pet-battle-api/reports/latest/index.html"

echo "install-allure done"
