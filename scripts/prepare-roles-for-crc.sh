#!/bin/bash

set -xeuo pipefail

for role in $(oc get clusterroles | grep -E '(route|secret|namespace|service|deployment)get' | awk '{ print $1 }'); do
    oc delete clusterrole $role 
done
oc create clusterrole routeget --verb=get,create,list,watch,patch,update,delete --resource=route
oc adm policy add-role-to-user routeget system:serviceaccount:default:default
oc create clusterrole secretget --verb=get,create,list,watch,patch,update,delete --resource=secret
oc adm policy add-role-to-user secretget system:serviceaccount:default:default
oc create clusterrole namespaceget --verb=get,create,list,watch,patch,update,delete --resource=namespace
oc adm policy add-role-to-user namespaceget system:serviceaccount:default:default
oc create clusterrole serviceget --verb=get,create,list,watch,patch,update,delete --resource=service
oc adm policy add-role-to-user serviceget system:serviceaccount:default:default
oc create clusterrole deploymentget --verb=get,create,list,watch,patch,update,delete --resource=deployment
oc adm policy add-role-to-user deploymentget system:serviceaccount:default:default
oc adm policy add-scc-to-user privileged system:serviceaccount:default:default
