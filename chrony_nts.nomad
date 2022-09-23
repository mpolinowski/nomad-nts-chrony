job "chrony_nts" {
    datacenters = ["chronyNTS"]
    type = "service"

    group "docker" {
        count = 1

        network {
            // mode = "host"
            port "ntp" {
                static = "123"
            }
            port "nts" {
                static = "4460"
            }
        }

        update {
            max_parallel = 1
            min_healthy_time = "10s"
            healthy_deadline = "2m"
            progress_deadline = "5m"
            auto_revert = true
            auto_promote = true
            canary = 1
        }

        service {
            name = "NTS"
            port = "nts"

            check {
                name = "NTS Service"
                type = "tcp"
                interval = "10s"
                timeout = "1s"
            }
        }

        volume "letsencrypt" {
            type      = "host"
            read_only = false
            source    = "letsencrypt"
        }

        task "chrony_container" {
            driver = "docker"
            volume_mount {
                volume      = "letsencrypt"
                destination = "/opt/letsencrypt"
                read_only   = false
           }

            env {
                NTP_SERVERS = "0.de.pool.ntp.org,time.cloudflare.com,time1.google.com"
                LOG_LEVEL = "1"
            }

            config {
                image = "my.gitlab.com:12345/chrony-nts:latest"
                ports = ["ntp", "nts"]
                network_mode = "default"
                force_pull = true

                auth {
                    username = "mygitlabuser"
                    password = "supersecret"
                }
            }
        }
    }
}