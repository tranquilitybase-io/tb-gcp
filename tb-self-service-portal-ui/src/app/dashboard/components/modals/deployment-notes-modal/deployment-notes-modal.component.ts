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

import { Component, Input, OnInit } from '@angular/core';
import { NgbActiveModal, NgbModal } from '@ng-bootstrap/ng-bootstrap';
import { DeploymentsService } from 'src/app/dashboard/services/deployments.service';
import { FormGroup, FormControl } from '@angular/forms';

@Component({
  selector: 'tb-ssp-deployment-notes-modal',
  template: `
    <form [formGroup]="deploymentNotesForm">
      <div class="modal-header">
        <h4 class="modal-title">Deployment notes</h4>
      </div>
      <div class="modal-body">
        <textarea class="form-control" formControlName="deploymentNoteValue">{{ deploymentNote }}</textarea>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-cancel btn-outline-secondary" (click)="activeModal.close('Close click')">Cancel</button>
        <button type="button" class="btn btn-remove-deployment btn-danger"
          (click)="setDeploymentNote(id)">Save deployment notes</button>
      </div>
    </form>
  `
})

export class DeploymentNotesModalComponent implements OnInit {
  @Input() id;
  deploymentNote: string;

  constructor(
    public activeModal: NgbActiveModal,
    private deploymentsService: DeploymentsService) {}

  deploymentNotesForm = new FormGroup({
    deploymentNoteValue: new FormControl('')
  });

  setDeploymentNote(id) {
    this.deploymentsService.updateDeployment(id, { deploymentNotes: this.deploymentNotesForm.value.deploymentNoteValue}).subscribe();
    this.activeModal.close();
  }

  ngOnInit() {
    const deploymentNote = this.deploymentsService.getDeploymentNote(this.id);

    deploymentNote.subscribe((deploymentNoteVal) => {
      this.deploymentNotesForm.patchValue({
        deploymentNoteValue: deploymentNoteVal.deploymentNotes
      });
    });
  }
}
