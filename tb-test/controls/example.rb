# copyright: 2018, The Authors

title "GCP compute instance groups"

gcp_project_id = input("gcp_project_id")
# Controls
control "gcp-single-region-1.0" do                                                    # A unique ID for this control
  impact 1.0                                                                          # The criticality, if this control fails.
  title "Ensure instance group exists."                            # A human-readable title
  desc "An optional description..."
  describe google_compute_instance_group(project: gcp_project_id, zone: 'europe-west2-a', name: 'gke-gke-ssp-gke-ssp-node-pool-f7d86e1e-grp') do
	it { should exist }
  end
end

