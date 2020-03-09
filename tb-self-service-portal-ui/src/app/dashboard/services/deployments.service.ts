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

import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { map } from 'rxjs/operators';
import Dexie from 'dexie';
import { DeploymentsIDBs } from 'src/app/models/deploymentsIDB.model';
import { IndexedDb } from './indexeddb.service';
import { from, Observable } from 'rxjs';

@Injectable()
export class DeploymentsService {

    deploymentsList: Dexie.Table<DeploymentsIDBs, number>;

    constructor(private http: HttpClient, private indexeddb: IndexedDb) {
        this.deploymentsList = this.indexeddb.table('deployments');
    }

    DEPLOYMENTS_API_URL = 'http://localhost:3000/api/deployments/';

    getDeployment(id): any {
        return from(this.deploymentsList.get(id))
            .pipe(
                map((res) => res));
    }

    getAllDeployments(): Observable<DeploymentsIDBs[]> {
        return from(this.deploymentsList.toArray());
    }

    addDeployment(data) {
        return from(this.deploymentsList.add(data));
    }

    updateDeployment(id, data) {
        return from(this.deploymentsList.update(id, data));
    }

    removeDeployment(id) {
        return from(this.deploymentsList.delete(id));
    }

    getDeploymentNote(id) {
        return from(this.deploymentsList.get(id))
            .pipe(
                map((res) => res));

    }

    setDeploymentNote(id, value) {
        return from(this.deploymentsList.update(id, { deploymentNotes: value } ));
    }

    // getDeployment(id): any {
    //     return this.http.get(`${this.DEPLOYMENTS_API_URL}${id}`)
    //         .pipe(
    //             map((res) => res)
    //         );
    // }

    // getDeployments(): any {
    //     return this.http.get(`${this.DEPLOYMENTS_API_URL}`)
    //         .pipe(
    //             map((res) => res)
    //         );
    // }

    // removeDeployment(id) {
    //     return this.http.delete(`${this.DEPLOYMENTS_API_URL}${id}`);
    // }

    // getDeploymentNote(id) {
    //     return this.http.get(`${this.DEPLOYMENTS_API_URL}note/${id}`);
    // }

    // setDeploymentNote(id, content) {
    //     return this.http.put(`${this.DEPLOYMENTS_API_URL}note/${id}`, content);
    // }
}
