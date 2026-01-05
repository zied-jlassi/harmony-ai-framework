---
name: "ansible"
description: "Ansible IaC patterns for OVH server"
version: "1.0"
auto_invoke: true
activate_when:
  file_matches:
    - "ansible/**"
    - "*.yml"
    - "playbook*.yaml"
  keywords:
    - "ansible"
    - "playbook"
    - "ovh"
    - "deploy"
    - "infrastructure"
agents:
  - devops
---

# Ansible Patterns

> Patterns Ansible pour serveur OVH

## Project Structure

```
ansible/
├── inventories/
│   ├── production/hosts.yml
│   └── staging/hosts.yml
├── roles/
│   ├── common/
│   ├── nodejs/
│   ├── nginx/
│   └── docker/
├── playbooks/
│   ├── site.yml
│   └── deploy.yml
├── group_vars/
│   └── all/
│       ├── vars.yml
│       └── vault.yml  # Encrypted
└── ansible.cfg
```

## Inventory Template

```yaml
# inventories/production/hosts.yml
all:
  children:
    webservers:
      hosts:
        ovh-vps:
          ansible_host: "{{ vault_ovh_ip }}"
          ansible_user: "{{ vault_ssh_user }}"
          ansible_ssh_private_key_file: ~/.ssh/ovh_key
  vars:
    ansible_python_interpreter: /usr/bin/python3
```

## Deployment Playbook

```yaml
# playbooks/deploy.yml
- name: Deploy Application
  hosts: webservers
  become: true
  vars:
    app_name: myapp
    app_dir: /opt/{{ app_name }}

  tasks:
    - name: Clone repository
      ansible.builtin.git:
        repo: "{{ vault_git_repo }}"
        dest: "{{ app_dir }}"
        version: main
      notify: restart app

    - name: Install dependencies
      community.general.npm:
        path: "{{ app_dir }}"

    - name: Run migrations
      ansible.builtin.command:
        cmd: npx prisma migrate deploy
        chdir: "{{ app_dir }}"

  handlers:
    - name: restart app
      ansible.builtin.systemd:
        name: "{{ app_name }}"
        state: restarted
```

## Vault (Secrets)

```bash
# Create encrypted file
ansible-vault create group_vars/all/vault.yml

# Edit encrypted file
ansible-vault edit group_vars/all/vault.yml

# Run with vault
ansible-playbook site.yml --ask-vault-pass
```

```yaml
# vault.yml (encrypted)
vault_database_password: "secret"
vault_jwt_secret: "jwt-secret"
vault_ovh_ip: "1.2.3.4"
```

## Idempotence Patterns

```yaml
# WRONG - Not idempotent
- name: Add line
  ansible.builtin.shell: echo "line" >> /etc/config

# CORRECT - Idempotent
- name: Ensure line in file
  ansible.builtin.lineinfile:
    path: /etc/config
    line: "line"
    state: present
```

## Molecule Testing

```bash
# Run role tests
cd roles/nodejs
molecule test

# Only converge
molecule converge
```

## Security Checklist

- [ ] All secrets in Vault
- [ ] SSH key auth only
- [ ] UFW configured
- [ ] fail2ban enabled
- [ ] No passwords in playbooks

## References

- OVH Server: `.claude/memory/OVH_SERVER.md`
- Vault password: Never in git
