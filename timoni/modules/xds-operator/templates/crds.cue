package templates

// ListenerCRD defines the Listener CRD for xDS
#ListenerCRD: {
	#config: #Config
	
	apiVersion: "apiextensions.k8s.io/v1"
	kind:       "CustomResourceDefinition"
	metadata: {
		name:   "listeners.xds.nebucloud.io"
		labels: #config.metadata.labels
	}
	
	spec: {
		group: "xds.nebucloud.io"
		names: {
			kind:     "Listener"
			listKind: "ListenerList"
			plural:   "listeners"
			singular: "listener"
			shortNames: ["xl"]
		}
		scope: "Namespaced"
		versions: [
			{
				name:    "v1alpha1"
				served:  true
				storage: true
				
				subresources: {
					status: {}
				}
				
				additionalPrinterColumns: [
					{
						name:     "Address"
						type:     "string"
						jsonPath: ".spec.address"
					},
					{
						name:     "Port"
						type:     "integer"
						jsonPath: ".spec.port"
					},
					{
						name:     "Status"
						type:     "string"
						jsonPath: ".status.conditions[?(@.type==\"Ready\")].status"
					},
					{
						name:     "Age"
						type:     "date"
						jsonPath: ".metadata.creationTimestamp"
					},
				]
				
				schema: {
					openAPIV3Schema: {
						type: "object"
						properties: {
							spec: {
								type: "object"
								properties: {
									name: {
										type:        "string"
										description: "Name of the listener"
									}
									address: {
										type:        "string"
										description: "Address to bind the listener to"
									}
									port: {
										type:        "integer"
										format:      "int32"
										minimum:     1
										maximum:     65535
										description: "Port to bind the listener to"
									}
									tls: {
										type: "object"
										properties: {
											mode: {
												type: "string"
												enum: ["DISABLED", "SIMPLE", "MUTUAL"]
											}
											certificateRef: {
												type: "object"
												properties: {
													name: {
														type: "string"
													}
													namespace: {
														type: "string"
													}
												}
												required: ["name"]
											}
										}
										required: ["mode"]
									}
									routes: {
										type: "array"
										items: {
											type: "object"
											properties: {
												name: {
													type: "string"
												}
												match: {
													type: "object"
													properties: {
														prefix: {
															type: "string"
														}
														path: {
															type: "string"
														}
														regex: {
															type: "string"
														}
													}
													oneOf: [
														{
															required: ["prefix"]
														},
														{
															required: ["path"]
														},
														{
															required: ["regex"]
														},
													]
												}
												route: {
													type: "object"
													properties: {
														cluster: {
															type: "string"
														}
														timeout: {
															type: "string"
														}
													}
													required: ["cluster"]
												}
											}
											required: ["name", "match", "route"]
										}
									}
								}
								required: ["name", "port"]
							}
							status: {
								type: "object"
								properties: {
									observedGeneration: {
										type:   "integer"
										format: "int64"
									}
									conditions: {
										type: "array"
										items: {
											type: "object"
											properties: {
												type: {
													type: "string"
												}
												status: {
													type: "boolean"
												}
												reason: {
													type: "string"
												}
												message: {
													type: "string"
												}
												lastTransitionTime: {
													type:   "string"
													format: "date-time"
												}
											}
											required: ["type", "status"]
										}
									}
								}
							}
						}
					}
				}
			},
		]
	}
}