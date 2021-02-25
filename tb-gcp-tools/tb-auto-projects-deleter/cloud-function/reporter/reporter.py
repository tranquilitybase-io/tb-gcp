from datetime import datetime
from tabulate import tabulate


def get_stubborn_projects(delete_list: list, end_projects: list, start_projects: list) -> list:
    stubborn_projects = []
    for deleteId in delete_list:
        filtered = list(filter(lambda proj: proj['projectNumber'] == deleteId, end_projects))
        if filtered:
            stubborn_projects.append(filtered[0]["projectNumber"])
        else:
            stubborn_projects.append("Error assessing project " + deleteId)

    return stubborn_projects


def pretty_print_project(id: str, start_projects: list) -> list:

    filtered = list(filter(lambda proj: proj['projectNumber'] == id, start_projects))
    if filtered:
        project_details = filtered[0]
        project_number = str(project_details['projectNumber'])
        project_id = str(project_details['projectId'])

        # labels
        created_by = "not available"
        owner = "not available"
        if 'labels' in project_details:
            if 'created_by' in project_details['labels']:
                created_by = str(project_details['labels']['created_by'])

            if 'owner' in project_details['labels']:
                owner = str(project_details['labels']['owner'])

        entry = [str(project_number), project_id, created_by, owner]
        return entry
    else:
        entry = ['na', id, 'na', 'na']
        return entry


def generate_projects(projects: list, title: str, start_projects: list) -> str:
    if not projects:
        return ""

    report = "\n"
    report += "<pre>"
    report += title + "\n"
    table = []
    for p in projects:
        table.append(pretty_print_project(p, start_projects))

    report += tabulate(table, headers=['id', 'name', 'created_by', 'owner'], stralign="left")
    report += "</pre>"
    return report


def get_date() -> str:
    return datetime.today().strftime('%Y-%m-%d')


def generate_report(dry_run: bool, run_start: str, duration: str,
                    deleted_projects: list, full_empty_folder_list: list,
                    kept_projects: list, conflicted_projects: list,
                    start_projects: list, end_projects: list):

    stubborn_projects = get_stubborn_projects(deleted_projects, end_projects, start_projects)

    print("++++++++++++++++++++++++++")
    report = "\n"
    if dry_run:
        report += "[is DRY RUN]" + "\n"

    report += "<strong>Cleanup Report:</strong>" + "\n"
    report += "Run at " + get_date() + ", " + str(run_start) + " (duration: " + duration + " secs)" + "\n"
    report += generate_projects(deleted_projects, "Deleted:", start_projects) + "\n"
    report += generate_projects(full_empty_folder_list, "Empty folders removed:", start_projects) + "\n"
    report += generate_projects(kept_projects, "Kept:", start_projects) + "\n"
    if dry_run:
        report += generate_projects(conflicted_projects, "Conflicted:", start_projects) + "\n"
    else:
        report += generate_projects(conflicted_projects, "Conflicted:", start_projects) + "\n"
        report += generate_projects(stubborn_projects, "Stubborn:", start_projects) + "\n"
    
    print(report)
    print("++++++++++++++++++++++++++")
    return report
