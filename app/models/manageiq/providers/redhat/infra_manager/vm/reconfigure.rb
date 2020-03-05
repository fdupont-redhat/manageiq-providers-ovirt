module ManageIQ::Providers::Redhat::InfraManager::Vm::Reconfigure
  # Show Reconfigure VM task
  def reconfigurable?
    active?
  end

  def max_total_vcpus
    # the default value of MaxNumOfVmCpusTotal for RHEV 3.1 - 3.4
    160
  end

  def max_cpu_cores_per_socket
    # the default value of MaxNumOfCpuPerSocket for RHEV 3.1 - 3.4
    16
  end

  def max_vcpus
    # the default value of MaxNumofVmSockets for RHEV 3.1 - 3.4
    16
  end

  def max_memory_mb
    2.terabyte / 1.megabyte
  end

  def available_vlans
    vlans = host.lans.pluck(:name)

    vlans.sort.concat(available_external_vlans)
  end

  def available_external_vlans
    ext_vlans = parent_datacenter.external_distributed_virtual_lans.map { |lan| "#{lan.name}/#{lan.switch.name}" }

    ext_vlans.sort
  end

  def build_config_spec(task_options)
    {
      "numCoresPerSocket" => (task_options[:cores_per_socket].to_i if task_options[:cores_per_socket]),
      "memoryMB"          => (task_options[:vm_memory].to_i if task_options[:vm_memory]),
      "numCPUs"           => (task_options[:number_of_cpus].to_i if task_options[:number_of_cpus]),
      "disksRemove"       => task_options[:disk_remove],
      "disksAdd"          => (spec_for_added_disks(task_options[:disk_add]) if task_options[:disk_add])
    }
  end

  def spec_for_added_disks(disks)
    {
      :disks   => disks,
      :storage => storage
    }
  end
end
