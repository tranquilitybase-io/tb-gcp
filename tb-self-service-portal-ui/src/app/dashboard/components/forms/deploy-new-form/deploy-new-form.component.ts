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
import { faTimes} from '@fortawesome/free-solid-svg-icons';
import { FormGroup, FormControl } from '@angular/forms';
import { ActivatedRoute, Router } from '@angular/router';
import { DeploymentsService } from 'src/app/dashboard/services/deployments.service';

@Component({
  selector: 'tb-ssp-deploy-new-form',
  templateUrl: './deploy-new-form.component.html',
  styleUrls: ['./deploy-new-form.component.scss']
})
export class DeployNewFormComponent implements OnInit {

  constructor(
    public router: Router,
    public activatedRoute: ActivatedRoute,
    private deploymentsService: DeploymentsService) { }

  closeIcon = faTimes;

  developNewForm = new FormGroup({
    activatorId: new FormControl(this.activatedRoute.snapshot.paramMap.get('id')),
    selectedBranches: new FormControl(''),
    selectedDeployNewEnvIds: new FormControl(''),
    selectedDeploymentTags: new FormControl(''),
    deploymentNotes: new FormControl('')
  });

  selectedBranches;
  deploymentTags: any[] = [];
  branches: any[] = [];

  environmentTypes: any[] = [
    { id: 1, name: 'Azure' },
    { id: 2, name: 'GCP' },
    { id: 3, name: 'AWS'},
  ];

  selectedDeploymentTags = ['Prod', 'Dev', 'Staging'];

  addTagFn(name) {
    return { name, tag: true };
  }

  addDeploymentTagFn(name) {
    return name;
  }

  tagsTrackByFn(index, tag) {
    return tag.id;
  }

  clearEnvironmentTagsModel() {
    this.selectedDeploymentTags = [];
  }

  deploy() {
    const pageId = this.activatedRoute.snapshot.paramMap.get('id');
    this.deploymentsService.addDeployment(this.developNewForm.value);
    this.router.routeReuseStrategy.shouldReuseRoute = () => false;
    this.router.onSameUrlNavigation = 'reload';
    this.router.navigate([`/activators/${pageId}`]);
  }

  ngOnInit() {
    this.selectedDeploymentTags.forEach((tagName, tagIndex) => {
      this.deploymentTags.push(tagName);
   });
  }

}
