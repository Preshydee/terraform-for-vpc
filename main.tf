provider "google" {
  credentials = file("cloud-school-324900-a75076a0a041.json")
  project     = "cloud-school-324900"
  region      = "us-east1"
}

# Main VPC
resource "google_compute_network" "main3" {
  name                    = "main3"
  auto_create_subnetworks = false
}
# Public Subnet
# https://www.terraform.io/docs/providers/google/r/compute_subnetwork.html
resource "google_compute_subnetwork" "public" {
  name          = "public"
  ip_cidr_range = "10.0.0.0/24"
  region        = "us-east1"
  network       = google_compute_network.main3.id
}

# Private Subnet
# https://www.terraform.io/docs/providers/google/r/compute_subnetwork.html
resource "google_compute_subnetwork" "private" {
  name          = "private"
  ip_cidr_range = "172.16.0.0/12"
  region        = "us-east1"
  network       = google_compute_network.main3.id
}
# Cloud Router
# https://www.terraform.io/docs/providers/google/r/compute_router.html
resource "google_compute_router" "router" {
  name    = "router"
  network = google_compute_network.main3.id
  bgp {
    asn            = 64514
    advertise_mode = "CUSTOM"
  }
}

# NAT Gateway
# https://www.terraform.io/docs/providers/google/r/compute_router_nat.html
resource "google_compute_router_nat" "nat" {
  name                               = "nat"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = "private"
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}
