// Copyright 2019 The Tranquility Base Authors
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//     http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import { Component, OnInit } from '@angular/core';
import { NgbModal } from '@ng-bootstrap/ng-bootstrap';
import { faTimes} from '@fortawesome/free-solid-svg-icons';
import { RemoveDeploymentModalComponent } from '../../modals/remove-deployment-modal/remove-deployment-modal.component';
import { DeploymentNotesModalComponent } from '../../modals/deployment-notes-modal/deployment-notes-modal.component';
import { DeploymentsService } from 'src/app/dashboard/services/deployments.service';
import { DeploymentsIDBs } from 'src/app/models/deploymentsIDB.model';

@Component({
  selector: 'tb-ssp-active-deployments-form',
  templateUrl: './active-deployments-form.component.html',
  styleUrls: ['./active-deployments-form.component.scss']
})
export class ActiveDeploymentsFormComponent implements OnInit {

  constructor(private modalService: NgbModal, private deploymentsService: DeploymentsService) { }
  deploymentsIDBs: DeploymentsIDBs[] = [];

  closeIcon = faTimes;

// appDeploymentTags: any[] = [
//   { id: 1, tag: 'Deployment tag', env: 'Azure', notes: 'example deployment note' },
//   { id: 2, tag: 'Apache', env: 'Google Cloud Platform', notes: 'standard server' },
//   { id: 3, tag: 'Bank system test', env: 'AWS', notes: 'banking system boilerplate' },
//   { id: 4, tag: 'Insurance', env: 'AWS', notes: 'Insurance company system' },
//   { id: 5, tag: 'Company', env: 'Google Cloud Platform', notes: 'Internal company product' }
// ];

environmentTypes: any[] = [
  { id: 1, name: 'Azure' },
  { id: 2, name: 'GCP' },
  { id: 3, name: 'AWS'},
];

removeEnvironmentModal(id) {
  const modalRef = this.modalService.open(RemoveDeploymentModalComponent, {
    backdropClass: 'remove-environment-modal',
    windowClass: 'remove-environment-backdrop',
    centered: true
  });
  modalRef.componentInstance.id = id;
}

deploymentNotesModal(id) {
  const modalRef = this.modalService.open(DeploymentNotesModalComponent, {
    backdropClass: 'remove-environment-modal',
    windowClass: 'remove-environment-backdrop',
    centered: true
  });
  modalRef.componentInstance.id = id;
}

  ngOnInit() {
    const activeDeploymentsObservable = this.deploymentsService.getAllDeployments();

    activeDeploymentsObservable.subscribe((deploymentsIDBsData: DeploymentsIDBs[]) => {



      this.deploymentsIDBs = deploymentsIDBsData;
    });
  }

}
