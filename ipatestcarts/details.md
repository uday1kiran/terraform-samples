create a helmfile for installing below applications.And give me complete step by step instructions treating me as a layman.
1. application name keycloak and image quay.io/keycloak:18.0.0 and url https://idp-alpha.ipas-test.com should deploy to node label keycloak=yes
2. application name kie-server and image jboss/jbpm-server-full:7.59.0.Final and url https://bpm-alpha.ipas-test.com should deploy to node label kie-server=yes
3. application name elasticsearch and image elasticsearch:7.17.5 and url https://idx-alpha.ipas-test.com should deploy to node label elasticsearch=yes
4. application name kibana and image kibana:7.17.5 and url https://log-alpha.ipas-test.com should deploy to node label kibana=yes
5. application name pghero and image ankane/pghero:v3.3.3 and url https://dba-alpha.ipas-test.com  should deploy to node label pghero=yes
6. application name kubernetes-dashboard and image kubernetes/dashboard:v2.6.0 and url https://kub-alpha.ipas-test.com should deploy to node label kubernetes-dashboard=yes
7. application name grafana and image Grafana/grafana:7.3.7 and url https://das-monitor.ipas-test.com 
8. application name jaeger-query and image jaegertracing/jaeger-query:1.45.0 and url https://trc-monitor.ipas-test.com should deploy to node label jaeger-query=yes
9. application name kafdrop and image obsidiandynamics/kafdrop:3.31.0 and url https://msg-alpha.ipas-test.com should deploy to node label kafdrop=yes

