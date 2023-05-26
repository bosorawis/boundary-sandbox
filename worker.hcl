name = "private-worker"
disable_mlock = true
listener "tcp" {
  purpose = "proxy"
  address = "0.0.0.0:9200"
}

hcp_boundary_cluster_id = "d27adf55-1bb5-4752-a419-ae2b03efbf18"

worker {
  auth_storage_path = "/boundary/auth/worker1"
  tags {
    type = ["worker1", "downstream"]
  }
}