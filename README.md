# Priorityqueues
Mikrotik script to modify download and upload priorities
This is a script that, given a simple queue scheme with a parent queue called Uplink, modifies the download and upload priority of the child simple queues based on the upload and download traffic that passed through those queues. The idea is to penalize the queues with higher traffic. Run the script in the scheduler to adjust the priorities over time.
