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

import { Component, Input } from '@angular/core';
import { NgbActiveModal, NgbModal } from '@ng-bootstrap/ng-bootstrap';
import { DeploymentsService } from 'src/app/dashboard/services/deployments.service';
import { ActivatedRoute, Router } from '@angular/router';

@Component({
  selector: 'tb-ec-remove-deployment-modal',
  template: `
    <div class="modal-header">
      <h4 class="modal-title">Remove Deployment</h4>
    </div>
    <div class="modal-body">
      <p>Are you sure you want to remove this deployment?</p>
      <p>Deployment ID: {{ id }}</p>
    </div>
    <div class="modal-footer">
      <button type="button" class="btn btn-cancel btn-outline-secondary" (click)="activeModal.close('Close click')">Cancel</button>
      <button type="button" class="btn btn-remove-deployment btn-danger" (click)="removeDeployment(id)">Remove deployment</button>
    </div>
  `
})

export class RemoveDeploymentModalComponent {
  @Input() id;

  constructor(
    public activeModal: NgbActiveModal,
    private deploymentsService: DeploymentsService,
    private router: Router,
    private activatedRoute: ActivatedRoute,
    private modalService: NgbModal) {}

  removeDeployment(id) {
    const pageId = this.activatedRoute.snapshot.children[0].params.id;
    this.deploymentsService.removeDeployment(id).subscribe();
    this.router.routeReuseStrategy.shouldReuseRoute = () => false;
    this.router.onSameUrlNavigation = 'reload';
    this.router.navigate([`/activators/${pageId}`]);
    this.activeModal.close();
  }
}
