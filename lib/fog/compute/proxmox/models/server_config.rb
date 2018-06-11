# frozen_string_literal: true

# Copyright 2018 Tristan Robert

# This file is part of Fog::Proxmox.

# Fog::Proxmox is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# Fog::Proxmox is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with Fog::Proxmox. If not, see <http://www.gnu.org/licenses/>.

require 'fog/proxmox/variables'
require 'fog/proxmox/nic'

module Fog
  module Compute
    class Proxmox
      # ServerConfig model
      class ServerConfig < Fog::Proxmox::Model
        identity  :digest
        attribute :description
        attribute :ostype
        attribute :smbios1
        attribute :numa
        attribute :vcpus
        attribute :cores
        attribute :bootdisk
        attribute :onboot
        attribute :agent
        attribute :scsihw
        attribute :sockets
        attribute :memory
        attribute :min_memory
        attribute :shares
        attribute :balloon
        attribute :name
        attribute :cpu
        attribute :cpulimit
        attribute :cpuunits
        attribute :server

        def initialize(attributes = {})
          prepare_service_value(attributes)
          Fog::Proxmox::Variables.to_variables(self, attributes, 'net')
          Fog::Proxmox::Variables.to_variables(self, attributes, 'virtio')
          Fog::Proxmox::Variables.to_variables(self, attributes, 'scsi')
          Fog::Proxmox::Variables.to_variables(self, attributes, 'sata')
          Fog::Proxmox::Variables.to_variables(self, attributes, 'ide')
          super({ server: server }.merge(attributes))
        end

        def nics
          Fog::Proxmox::Variables.to_hash(self, 'net')
        end

        def virtios
          Fog::Proxmox::Variables.to_hash(self, 'virtio')
        end

        def ides
          Fog::Proxmox::Variables.to_hash(self, 'ide')
        end

        def statas
          Fog::Proxmox::Variables.to_hash(self, 'sata')
        end

        def scsis
          Fog::Proxmox::Variables.to_hash(self, 'scsi')
        end

        def mac_addresses
          Fog::Proxmox::Nic.to_mac_adresses_array(nics)
        end

        def next_nicid
          Fog::Proxmox::Nic.last_index(nics)
        end

        def cpu_type
          cpu_extract[0] if cpu_extract
        end

        def spectre
          cpu_has? '+spec-ctrl'
        end

        def pcid
          cpu_has? '+pcid'
        end
        
        private

        def cpu_extract
          cpu.split(/(\w+)(,flags=){0,1}(\+[\w-]+){0,1}[;]{0,1}(\+[\w-]+){0,1}/) if cpu
        end

        def cpu_has?(value)
          cpu_extract.include? value if cpu_extract
        end

      end
    end
  end
end
