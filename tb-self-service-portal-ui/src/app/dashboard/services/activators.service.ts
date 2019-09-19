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
import { HttpClient, HttpHeaders } from '@angular/common/http';

import Dexie from 'dexie';
import { from, Observable, throwError, iif } from 'rxjs';
import { map, mergeMap, catchError, tap, filter } from 'rxjs/operators';

import { ActivatorsIDBs } from '../../models/activatorsIDB.model';
import { IndexedDb } from './indexeddb.service';
import { UNSUBSTITUTED_API_URL } from '../../constants';
import { Activator } from 'src/app/models/activators.model';

@Injectable()
export class ActivatorsService {

    private activatorsList: Dexie.Table<ActivatorsIDBs, number>;

    private ACTIVATORS_API_URL = 'http://localhost:3000/api/activators';
    private BUILD_API_URL = 'http://localhost:3000/api/build';

    public static readonly DEFAULT_API_PARAMS = {
        user: 'self-service-portal@project_id.iam.gserviceaccount.com',  // FIXME should this be in the API instead?
        tf_data: {}
    };

    constructor(private http: HttpClient, private indexeddb: IndexedDb) {
        this.activatorsList = this.indexeddb.table('activators');
    }

    getAllActivators(): Observable<ActivatorsIDBs[]> {
        return from(this.activatorsList.toArray());
    }

    addActivator(activator): Observable<string> {
        const postBody = Object.assign(  // need to include the user for now, so use defaults and then override with user inputs
            {},
            ActivatorsService.DEFAULT_API_PARAMS,
            activator.value,
            {
                // The current API just accepts an app_name, so temporarily stuff this into the payload.
                // When the API is updated to just use values from activator.value, this can be removed.
                app_name: activator.value.applicationName
            }
        );

        const headers = new HttpHeaders()
            .set('Content-Type', 'application/json');  // API is remote

        return this.prepareAddRequest(activator, postBody, headers).pipe(
            tap(() => from(this.activatorsList.add(activator))));
    }

    updateActivator(id, data) {
        return from(this.activatorsList.update(id, data));
    }

    removeActivator(id) {
        return from(this.activatorsList.delete(id));
    }

    getActivator(id): any {
        return from(this.activatorsList.get(id))
            .pipe(
                map((res) => res));
    }

    getActivators(): Observable<Activator[]> {
        return this.fetchActualApiUrl().pipe(
            filter((apiUrl: string) => apiUrl === UNSUBSTITUTED_API_URL),
            mergeMap(() =>
                this.http.get<Activator[]>(`${this.ACTIVATORS_API_URL}`)
            )
        );
    }

    private fetchActualApiUrl(): Observable<string> {
        return this.http.get('/assets/endpoint-meta.json', {
            responseType: 'text'
        });
    }

    private prepareAddRequest(activator, postBody: Object, headers: HttpHeaders): Observable<string> {
        return this.fetchActualApiUrl().pipe(
            mergeMap((apiUrl: string) =>
                iif(() => apiUrl !== UNSUBSTITUTED_API_URL,
                    this.http.post(`${apiUrl}/build`, postBody, { headers, responseType: 'text' }),
                    this.http.post(this.BUILD_API_URL, postBody, { headers, responseType: 'text' })
                ),
            ),
            catchError((error) => {
                return throwError(error);
            })
        );
    }
}
