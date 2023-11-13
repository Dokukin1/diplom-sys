


resource "yandex_compute_instance" "web-1" {
  name     = "web-1"
  hostname = "web-1"
  zone     = "ru-central1-a"

  resources {
    cores  = 2
    memory = 2

  }

  boot_disk {
    initialize_params {
      image_id = "fd80bm0rh4rkepi5ksdi"
      size     = 15
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private-subnet-1.id
    security_group_ids = [yandex_vpc_security_group.private-sg.id]
    ip_address         = "10.1.0.10"
  }

  metadata = {
    user-data = "${file("./meta.txt")}"

  }


}


resource "yandex_compute_instance" "web-2" {
  name     = "web-2"
  hostname = "web-2"
  zone     = "ru-central1-b"

  resources {
    cores  = 2
    memory = 2

  }

  boot_disk {
    initialize_params {
      image_id = "fd80bm0rh4rkepi5ksdi"
      size     = 15
    }

  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private-subnet-2.id
    security_group_ids = [yandex_vpc_security_group.private-sg.id]
    ip_address         = "10.2.0.10"
  }

  metadata = {
    user-data = "${file("./meta.txt")}"
  }



}

resource "yandex_compute_instance" "zabbix" {
  name     = "zabbix"
  hostname = "zabbix"
  zone     = "ru-central1-c"

  resources {
    cores  = 2
    memory = 6
  }

  boot_disk {
    initialize_params {
      image_id = "fd80bm0rh4rkepi5ksdi"
      type     = "network-ssd"
      size     = "15"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public-subnet.id
    security_group_ids = [yandex_vpc_security_group.private-sg.id, yandex_vpc_security_group.zabbix-sg.id]
    ip_address         = "10.4.0.20"
    nat                = true

  }

  metadata = {
    user-data = "${file("./meta.txt")}"
  }


}


resource "yandex_compute_instance" "elasticsearch" {
  name     = "elasticsearch"
  hostname = "elasticsearch"
  zone     = "ru-central1-c"

  resources {
    cores  = 4
    memory = 8

  }

  boot_disk {
    initialize_params {
      image_id = "fd80bm0rh4rkepi5ksdi"
      size     = 15
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private-subnet-3.id
    security_group_ids = [yandex_vpc_security_group.private-sg.id, yandex_vpc_security_group.elasticsearch-sg.id]
    ip_address         = "10.3.0.100"
  }

  metadata = {
    user-data = "${file("./meta.txt")}"
  }


}



resource "yandex_compute_instance" "kibana" {
  name     = "kibana"
  hostname = "kibana"
  zone     = "ru-central1-c"

  resources {
    cores  = 2
    memory = 2

  }

  boot_disk {
    initialize_params {
      image_id = "fd80bm0rh4rkepi5ksdi"
      size     = 15
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public-subnet.id
    security_group_ids = [yandex_vpc_security_group.private-sg.id, yandex_vpc_security_group.kibana-sg.id]
    ip_address         = "10.4.0.100"
    nat                = true

  }

  metadata = {
    user-data = "${file("./meta.txt")}"
  }


}
