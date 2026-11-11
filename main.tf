terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

provider "null" {}

# CI Kiểm tra code: Tự động chạy lại mỗi khi file index.html bị thay đổi
resource "null_resource" "ci_html_validation" {
  triggers = {
    # Mã hóa file index.html, cứ file này đổi nội dung là trigger kích hoạt chạy lại
    file_content = filesha256("D:\\DevOps-Network\\app\\index.html")
  }

  provisioner "local-exec" {
    command = "powershell -ExecutionPolicy Bypass -File D:\\DevOps-Network\\check_code.ps1"
  }
}

# CD Triển khai: Chỉ chạy khi CI không bị lỗi
resource "null_resource" "cd_deploy" {
  depends_on = [null_resource.ci_html_validation]

  provisioner "local-exec" {
    command = "start D:\\DevOps-Network\\app\\index.html"
  }
}