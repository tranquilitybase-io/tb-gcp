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

import { Component, OnInit, AfterViewInit } from '@angular/core';
import { ActivatorsService } from '../../services/activators.service';
import { NgbModal } from '@ng-bootstrap/ng-bootstrap';
import { FormBuilder, FormGroup, FormControl } from '@angular/forms';
import { Router, ActivatedRoute } from '@angular/router';
import { DeploymentsService } from '../../services/deployments.service';

@Component({
  selector: 'tb-ssp-application-setup',
  templateUrl: './application-setup.component.html',
  styleUrls: ['./application-setup.component.scss']
})

export class ApplicationSetupComponent implements OnInit {

  private loadActivator = false;

  constructor(
    private activatorsService: ActivatorsService,
    private deploymentsService: DeploymentsService,
    private fb: FormBuilder, private modalService: NgbModal,
    public router: Router, public activatedRoute: ActivatedRoute
    ) {}

    deploymentTagsModel;
    environmentTagsModel;
    currentJustify = 'fill';

    activator: object;

    branchesNames = ['user/testing/branch1', 'user/testing/sp2_task_test'];

    developmentSetupForm = new FormGroup({
      selectedCIIds: new FormControl(''),
      selectedCDIds: new FormControl(''),
      selectedSourceCtrlSystemsIds: new FormControl(''),
      selectedChangeControlIds: new FormControl(''),
      applicationName: new FormControl(''),
      applicationDescription: new FormControl('')
    });

    continuousIntegrationServices: any[] = [
        { id: 1, name: 'Jenkins' },
        { id: 2, name: 'Spinaker' },
        { id: 3, name: 'Gitlab CI', disabled: true },
    ];

    continuousDeliveryServices: any[] = [
      { id: 1, name: 'Codeship' },
      { id: 2, name: 'Testing 456' },
      { id: 3, name: 'Testing ....'},
    ];

    sourceControlServices: any[] = [
      { id: 1, name: 'JIRA' },
      { id: 2, name: 'Trello' },
      { id: 3, name: 'VSTS'},
    ];

    changeControlServices: any[] = [
      { id: 1, name: 'Remedy ITSM' },
      { id: 2, name: 'Other 1' },
      { id: 3, name: 'Other 2'},
    ];

  ngOnInit() {
    this.loadActivator = true;

    // const pageId = this.activatedRoute.params.value.id || 1;
    const pageId = 1;
    const activator = this.activatorsService.getActivator(pageId);

    activator.subscribe((activatorVal) => {
      this.activator = activatorVal;
    });
  }

   // this.branchesNames.forEach((c, i) => {
   //   this.branches.push({ id: i, name: c });
   // });
   // this.developNewForm = this.fb.group({
   //   selectedDeployNewEnvIds: []
   // });
  }
