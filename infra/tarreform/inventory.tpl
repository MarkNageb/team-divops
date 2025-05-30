[frontend]
3.92.203.67 ansible_user=ec2-user ansible_ssh_private_key_file=~/.ssh/vockey.pem

[backend]
52.23.208.227 ansible_user=ec2-user ansible_ssh_private_key_file=~/.ssh/vockey.pem

[genai]
44.201.110.23 ansible_user=ec2-user ansible_ssh_private_key_file=~/.ssh/vockey.pem

[all:vars]
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
ansible_python_interpreter=/usr/bin/python3.10