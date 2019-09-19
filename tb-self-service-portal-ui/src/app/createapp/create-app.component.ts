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
import { FormGroup, FormControl, Validators } from '@angular/forms';
import { Router } from '@angular/router';

import { faEllipsisV, faTimes } from '@fortawesome/free-solid-svg-icons';
import { merge } from 'rxjs';
import { map } from 'rxjs/operators';

import { ActivatorsService } from '../dashboard/services/activators.service';
import { DeploymentStatus } from '../models/deployment-status.enum';
import { CreatedApp } from './components/created-app';

@Component({
  selector: 'tb-ssp-create-app',
  templateUrl: './create-app.component.html',
  styleUrls: ['./create-app.component.scss']
})

export class CreateAppComponent implements OnInit {

  deploymentStatus: DeploymentStatus;

  constructor(private router: Router, private store: ActivatorsService) {
    this.deploymentStatus = DeploymentStatus.Idle;
    this.createdApp.updated = new Date();
  }

  DeploymentStatus = DeploymentStatus;
  dotMenuIcon = faEllipsisV;
  closeIcon = faTimes;
  createdApp: CreatedApp = {} as CreatedApp;
  data;

  businessOwnerMin = 3;
  techOwnerMin = 3;
  appNameMin = 2;
  descMin = 2;
  appNameMax = 255;
  descMax = 4000;

  createAppForm = new FormGroup({
    businessOwner: new FormControl('', [
      Validators.required,
      Validators.minLength(this.businessOwnerMin)
    ]),
    businessOwnerEmail: new FormControl('', [
      Validators.required,
      Validators.email
    ]),
    techOwnerName: new FormControl('', [
      Validators.required,
      Validators.minLength(this.techOwnerMin)
    ]),
    techOwnerEmail: new FormControl('', [
      Validators.required,
      Validators.email
    ]),
    costCentre: new FormControl('', [
      Validators.required
    ]),
    applicationName: new FormControl('', [
      Validators.required,
      Validators.minLength(this.appNameMin),
      Validators.maxLength(this.appNameMax)
    ]),
    applicationDescription: new FormControl('', [
      Validators.required,
      Validators.minLength(this.descMin),
      Validators.maxLength(this.descMax)
    ]),
    appUpdated: new FormControl(new Date())
  });

  get f() { return this.createAppForm.controls; }

  createApplication(value) {
    if (this.createAppForm.valid) {
      this.deploymentStatus = DeploymentStatus.InProgress;

      this.store.addActivator({ value }).subscribe(() => {
        this.deploymentStatus = DeploymentStatus.Finished;
      },
      () => {
        this.deploymentStatus = DeploymentStatus.FinishedWithError;
      });
    }
  }

  cancelForm() {
    this.createAppForm.reset();
    this.router.navigate(['/']);
  }

  ngOnInit() {
    merge(
      this.createAppForm.get('applicationName').valueChanges.pipe(map(value => ({ name: value }))),
      this.createAppForm.get('techOwnerName').valueChanges.pipe(map(value => ({ owner: value }))),
      this.createAppForm.get('applicationDescription').valueChanges.pipe(map(value => ({ description: value })))
    )
    .subscribe(value => {
      this.createdApp = { ...this.createdApp, ...value };
    });
  }
}
