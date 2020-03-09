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

import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FontAwesomeModule } from '@fortawesome/angular-fontawesome';
import { DashboardComponent } from './dashboard.component';
import { RouterModule } from '@angular/router';
import { DASHBOARD_ROUTES } from './dashboard.routes';
import { ActivatorsService } from './services/activators.service';
import { ApplicationSetupComponent } from './components/application-setup/application-setup.component';
import { CreateApplicationListComponent } from './components/createApplicationList/create-application-list.component';
import { DashboardFiltersComponent } from './components/filters/dashboard-filters.component';
import { ChangeViewComponent } from './components/changeView/change-view.component';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { NgSelectModule } from '@ng-select/ng-select';
import { NgbModule } from '@ng-bootstrap/ng-bootstrap';
import { CreateAppComponent } from './components/create-app/create-app.component';
import { IndexedDb } from './services/indexeddb.service';
import { RemoveDeploymentModalComponent } from './components/modals/remove-deployment-modal/remove-deployment-modal.component';
import { DeploymentNotesModalComponent } from './components/modals/deployment-notes-modal/deployment-notes-modal.component';
import { DeploymentsService } from './services/deployments.service';
import { ActiveDeploymentsFormComponent } from './components/forms/active-deployments-form/active-deployments-form.component';
import { DeployNewFormComponent } from './components/forms/deploy-new-form/deploy-new-form.component';
import { RedeploymentFormComponent } from './components/forms/redeployment-form/redeployment-form.component';
import { RedeploymentsService } from './services/redeployments.service';
import { ReversePipe } from './pipes/reverse/reverse.pipe';

@NgModule({
  declarations: [
    ChangeViewComponent,
    DashboardComponent,
    ApplicationSetupComponent,
    CreateApplicationListComponent,
    DashboardFiltersComponent,
    CreateAppComponent,
    RemoveDeploymentModalComponent,
    DeploymentNotesModalComponent,
    ActiveDeploymentsFormComponent,
    DeployNewFormComponent,
    RedeploymentFormComponent,
    ReversePipe,
  ],
  imports: [
    CommonModule,
    RouterModule,
    FormsModule,
    ReactiveFormsModule,
    NgbModule,
    NgSelectModule,
    FontAwesomeModule,
    RouterModule.forChild(DASHBOARD_ROUTES)
  ],
  providers: [
    ActivatorsService,
    DeploymentsService,
    RedeploymentsService,
    IndexedDb
  ],
  exports: [
    DashboardComponent,
    RemoveDeploymentModalComponent
  ],
  entryComponents: [
    RemoveDeploymentModalComponent,
    DeploymentNotesModalComponent
  ]
})
export class DashboardModule { }
