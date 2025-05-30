[frontend]
${frontend_ip} ansible_user=ec2-user ansible_ssh_private_key_file=${ssh_key}

[backend]
${backend_ip} ansible_user=ec2-user ansible_ssh_private_key_file=${ssh_key}

[genai]
${genai_ip} ansible_user=ec2-user ansible_ssh_private_key_file=${ssh_key}

[all:vars]
ansible_ssh_common_args='-o StrictHostKeyChecking=no'

