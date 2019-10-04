# copyright: 2018, The Authors

title "Sample Section"

gcp_project_id = attribute("gcp_project_id")

# you add controls here
control "gcp-single-region-1.0" do                                                    # A unique ID for this control
  impact 1.0                                                                          # The criticality, if this control fails.
  title "Ensure instance group exists."                            # A human-readable title
  desc "An optional description..."
  describe google_compute_instance_group(project: gcp_project_id, zone: 'europe-west2-c', name: 'gke-gke-ssp-gke-ssp-node-pool-0966deb4-grp') do
	it { should exist }
  end
end

