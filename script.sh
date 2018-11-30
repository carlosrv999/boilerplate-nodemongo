#!/bin/bash
appname=$1
replicas=$2
datesec=$(date +%s)
cat > mongodb-svc.yaml <<EOF
apiVersion: v1
kind: Service
metadata:
  creationTimestamp: null
  labels:
    cce/appgroup: $appname
    name: database$datesec
  name: mongodb$datesec
  selfLink: /api/v1/namespaces/default/services/mongodb$datesec
spec:
  ports:
  - name: mongodb0$datesec
    port: 27017
    protocol: TCP
    targetPort: 27017
  selector:
    cce/appgroup: $appname
    name: database$datesec
  sessionAffinity: None
  type: ClusterIP
status:
  loadBalancer: {}
EOF
cat > mongodb.yaml <<EOF
apiVersion: v1
kind: ReplicationController
metadata:
  annotations:
    cce/app-createTimestamp: 2018-11-22-21-01-55
    cce/app-description: ""
    cce/app-updateTimestamp: 2018-11-22-21-01-55
  creationTimestamp: null
  generation: 1
  labels:
    cce/appgroup: $appname
    name: database$datesec
    rollingupdate: "false"
  name: database$datesec
  selfLink: /api/v1/namespaces/default/replicationcontrollers/database$datesec
spec:
  replicas: 1
  selector:
    cce/appgroup: $appname
    name: database$datesec
    rollingupdate: "false"
  template:
    metadata:
      annotations:
        scheduler.alpha.kubernetes.io/affinity: '{"nodeAffinity":{"requiredDuringSchedulingIgnoredDuringExecution":{"nodeSelectorTerms":[{"matchExpressions":[{"key":"failure-domain.beta.kubernetes.io/zone","operator":"NotIn","values":[""]}]}]}}}'
      creationTimestamp: null
      labels:
        cce/appgroup: $appname
        name: database$datesec
        rollingupdate: "false"
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: failure-domain.beta.kubernetes.io/zone
                operator: NotIn
                values:
                - ""
      containers:
      - image: 100.125.0.23:6443/carlos.ramirezv/mongoalpine:3.6
        imagePullPolicy: IfNotPresent
        name: mongodb
        ports:
        - containerPort: 27017
          protocol: TCP
        resources: {}
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
        volumeMounts:
        - mountPath: /data/db
          name: volume-db$datesec
      dnsPolicy: ClusterFirst
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      terminationGracePeriodSeconds: 30
      volumes:
      - hostPath:
          path: /mongodb$datesec
        name: volume-db$datesec
status:
  replicas: 0
EOF
cat > backend-svc.yaml <<EOF
apiVersion: v1
kind: Service
metadata:
  creationTimestamp: null
  labels:
    cce/appgroup: $appname
    name: backend$datesec
  name: backend$datesec
  selfLink: /api/v1/namespaces/default/services/backend$datesec
spec:
  externalTrafficPolicy: Cluster
  ports:
  - name: backend0$datesec
    port: 3000
    protocol: TCP
    targetPort: 3000
  selector:
    cce/appgroup: $appname
    name: backend$datesec
  sessionAffinity: None
  type: NodePort
status:
  loadBalancer: {}
EOF
cat > backend.yaml <<EOF
apiVersion: v1
kind: ReplicationController
metadata:
  annotations:
    cce/app-createTimestamp: 2018-11-22-21-01-55
    cce/app-description: ""
    cce/app-updateTimestamp: 2018-11-22-21-01-55
  creationTimestamp: null
  generation: 1
  labels:
    cce/appgroup: $appname
    name: backend$datesec
    rollingupdate: "false"
  name: backend$datesec
  selfLink: /api/v1/namespaces/default/replicationcontrollers/backend$datesec
spec:
  replicas: $replicas
  selector:
    cce/appgroup: $appname
    name: backend$datesec
    rollingupdate: "false"
  template:
    metadata:
      annotations:
        scheduler.alpha.kubernetes.io/affinity: '{"nodeAffinity":{"requiredDuringSchedulingIgnoredDuringExecution":{"nodeSelectorTerms":[{"matchExpressions":[{"key":"failure-domain.beta.kubernetes.io/zone","operator":"NotIn","values":[""]}]}]}}}'
      creationTimestamp: null
      labels:
        cce/appgroup: $appname
        name: backend$datesec
        rollingupdate: "false"
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: failure-domain.beta.kubernetes.io/zone
                operator: NotIn
                values:
                - ""
      containers:
      - image: 100.125.0.23:6443/carlos.ramirezv/lboilerplate:1.1
        imagePullPolicy: IfNotPresent
        name: backend
        env: 
        - name: MONGODB_HOST
          value: "mongodb$datesec"
        ports:
        - containerPort: 3000
          protocol: TCP
        resources: {}
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
      dnsPolicy: ClusterFirst
      imagePullSecrets:
      - name: myregistry
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      terminationGracePeriodSeconds: 30
status:
  replicas: 0
EOF
