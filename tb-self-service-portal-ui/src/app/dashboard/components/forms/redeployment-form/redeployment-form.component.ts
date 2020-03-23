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
import { FormGroup, FormControl } from '@angular/forms';
import { ActivatedRoute, Router } from '@angular/router';
import { RedeploymentsService } from 'src/app/dashboard/services/redeployments.service';

@Component({
  selector: 'tb-ec-redeployment-form',
  templateUrl: './redeployment-form.component.html',
  styleUrls: ['./redeployment-form.component.scss']
})
export class RedeploymentFormComponent implements OnInit {

  constructor(
    private activatedRoute: ActivatedRoute,
    private router: Router,
    private redeploymentsService: RedeploymentsService) { }

  redeployForm = new FormGroup({
    redeploymentEnvironment: new FormControl(''),
    redeploymentTags: new FormControl(''),
    reasonForRedeploy: new FormControl('')
  });

  environmentTags: any[] = [];

  environmentTypes: any[] = [
    { id: 1, name: 'Azure' },
    { id: 2, name: 'GCP' },
    { id: 3, name: 'AWS'},
  ];

  addEnvTagFn(name) {
    return { name, tag: true };
  }

  redeploy() {
    const pageId = this.activatedRoute.snapshot.paramMap.get('id');
    this.redeploymentsService.addRedeployment(this.redeployForm.value);
    this.router.routeReuseStrategy.shouldReuseRoute = () => false;
    this.router.onSameUrlNavigation = 'reload';
    this.router.navigate([`/activators/${pageId}`]);
  }

  ngOnInit() {
  }

}
