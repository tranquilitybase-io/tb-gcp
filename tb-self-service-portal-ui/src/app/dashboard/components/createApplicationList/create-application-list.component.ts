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
import { faEllipsisV } from '@fortawesome/free-solid-svg-icons';
import { ActivatedRoute, ActivatedRouteSnapshot, Router } from '@angular/router';
import { Activator } from 'src/app/models/activators.model';
import { ActivatorsService } from '../../services/activators.service';
import { ActivatorsIDBs } from 'src/app/models/activatorsIDB.model';
import { merge } from 'rxjs';
import { tap } from 'rxjs/operators';

@Component({
  selector: 'tb-ec-create-application-list',
  templateUrl: './create-application-list.component.html',
  styleUrls: ['./create-application-list.component.scss']
})

export class CreateApplicationListComponent implements OnInit {
  dotMenuIcon = faEllipsisV;

  readonly id: number;
  private route: ActivatedRouteSnapshot;
  activators: Activator[] = [];
  activatorsIDBs: ActivatorsIDBs[] = [];
  private loadingActivators = false;

  constructor(
    activatedRoute: ActivatedRoute,
    private activatorsService: ActivatorsService) {
      this.id = activatedRoute.snapshot.data.id;
  }

  ngOnInit() {
    this.loadingActivators = true;
    const activators$ = this.activatorsService.getActivators().pipe(tap(activators => this.activators = activators));
    const activatorsIDB$ = this.activatorsService.getAllActivators().pipe(tap(activatorsIDBs => this.activatorsIDBs = activatorsIDBs));

    merge(activators$, activatorsIDB$)
      .subscribe(() => {
        this.loadingActivators = false;
      });
  }
}
