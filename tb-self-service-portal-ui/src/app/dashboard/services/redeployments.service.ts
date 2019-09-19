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
import { RedeploymentsIDBs } from 'src/app/models/redeploymentsIDB.model';
import { IndexedDb } from './indexeddb.service';
import { from, Observable } from 'rxjs';

@Injectable()
export class RedeploymentsService {

    redeploymentsList: Dexie.Table<RedeploymentsIDBs, number>;

    constructor(private http: HttpClient, private indexeddb: IndexedDb) {
        this.redeploymentsList = this.indexeddb.table('redeploymentLog');
    }

    DEPLOYMENTS_API_URL = 'http://localhost:3000/api/redeployments/';

    getRedeployment(id): any {
        return from(this.redeploymentsList.get(id))
            .pipe(
                map((res) => res));
    }

    getAllRedeployments(): Observable<RedeploymentsIDBs[]> {
        return from(this.redeploymentsList.toArray());
    }

    addRedeployment(data) {
        return from(this.redeploymentsList.add(data));
    }

    updateRedeployment(id, data) {
        return from(this.redeploymentsList.update(id, data));
    }

    removeRedeployment(id) {
        return from(this.redeploymentsList.delete(id));
    }
}
