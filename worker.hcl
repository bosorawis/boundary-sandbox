name = "private-worker"
disable_mlock = true
listener "tcp" {
  purpose = "proxy"
  address = "0.0.0.0:9200"
}

hcp_boundary_cluster_id = "472bfa07-4d2d-4bd9-8e96-fe429c9f7040"

worker {
  auth_storage_path = "/boundary/auth/worker1"
  tags {
    type = ["worker1", "downstream"]
  }
}