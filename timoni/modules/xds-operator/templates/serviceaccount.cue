package templates

import (
	corev1 "k8s.io/api/core/v1"
	rbacv1 "k8s.io/api/rbac/v1"
)

// ServiceAccount defines the xDS operator service account
#ServiceAccount: corev1.#ServiceAccount & {
	#config: #Config
	
	apiVersion: "v1"
	kind:       "ServiceAccount"
	metadata: {
		name:      #config.serviceAccount.name
		namespace: #config.metadata.namespace
		labels:    #config.metadata.labels
		if #config.serviceAccount.annotations != _|_ {
			annotations: #config.serviceAccount.annotations
		}
	}
}

// ClusterRole defines the RBAC permissions for the xDS operator
#ClusterRole: rbacv1.#ClusterRole & {
	#config: #Config
	
	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "ClusterRole"
	metadata: {
		name:   "\(#config.metadata.name)-role"
		labels: #config.metadata.labels
	}
	
	// We need to define rules more carefully to avoid list length incompatibilities
	// Using the rules defined in the config directly
	rules: #config.rbac.rules
}

// ClusterRoleBinding binds the ClusterRole to the ServiceAccount
#ClusterRoleBinding: rbacv1.#ClusterRoleBinding & {
	#config: #Config
	
	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "ClusterRoleBinding"
	metadata: {
		name:   "\(#config.metadata.name)-rolebinding"
		labels: #config.metadata.labels
	}
	
	roleRef: {
		apiGroup: "rbac.authorization.k8s.io"
		kind:     "ClusterRole"
		name:     "\(#config.metadata.name)-role"
	}
	
	subjects: [
		{
			kind:      "ServiceAccount"
			name:      #config.serviceAccount.name
			namespace: #config.metadata.namespace
		},
	]
}