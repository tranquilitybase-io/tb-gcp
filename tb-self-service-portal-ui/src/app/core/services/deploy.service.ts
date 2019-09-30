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

import { Injectable, Output, EventEmitter } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { ReplaySubject, Observable } from 'rxjs';
import {  } from 'rxjs/operators';

export interface DeployModel {
  app_name: string;
  app_description: string;
  provider: 'gcp' | 'aws';
  buss_owner_name: string;
  buss_owner_email: string;
  tech_owner_name: string;
  tech_owner_email: string;
  cost_centre: string;
};

@Injectable({
  providedIn: 'root'
})
export class DeployService {
  public static readonly PROVIDER_SPECIFIC_OPTS = {
    aws: {
      params: {
        bucket: 'terraform-state-ssp-2',
        terraform_url: 'https://github.com/tranquilitybase-io/tb-activator.git',
        user_role:  'arn:aws:iam::123456789012:role/fullPermissions',
        region: 'eu-central-1',
        env_data: 'dev.tfvars'
      }
    },
    gcp: {
      params: {
        bucket: 'terraformdevstate',
        terraform_url: 'https://github.com/tranquilitybase-io/tb-gcp-lz-pub/raw/master/terraform.zip'
      }
    }
  }

  public static readonly DEFAULT_PARAMS = {
    user: 'self-service-portal@project_id.iam.gserviceaccount.com',
    tf_data: { foo: 'bar' }
  };

  private apiUrlSubject: ReplaySubject<string> = new ReplaySubject(1);

  private apiUrlObservable: Observable<string> = this.apiUrlSubject.asObservable();

  @Output() deploySuccess: EventEmitter<boolean> = new EventEmitter();
  @Output() currentView: EventEmitter<string> = new EventEmitter();

  constructor (private httpClient: HttpClient) {
    this.fetchBackendUrl();
  }

  private fetchBackendUrl() {
    this.httpClient.get('/assets/endpoint-meta.json', {
      responseType: 'text'
    }).subscribe((url) => this.apiUrlSubject.next(String(url).trim()));
  }

  private sendDeployRequest(url, body) {
    this.httpClient.post(
      url + '/build',
      body,
      {
        responseType: 'text'
      }
    ).subscribe(
      (response: any) => {
        this.deploySuccess.emit(true);
      },
      (error: any) => {
        this.deploySuccess.emit(false);
      }
    );
  }

  public deploy(model: DeployModel) {
    const specific_opts = DeployService.PROVIDER_SPECIFIC_OPTS[model.provider];
    const body = Object.assign({},
      DeployService.DEFAULT_PARAMS,
      specific_opts.params,
      model
    );

    this.apiUrlObservable.subscribe(
      url => this.sendDeployRequest(url, body)
    );
  }

  public changeView(view: string) {
    this.currentView.emit(view);
  }
}
