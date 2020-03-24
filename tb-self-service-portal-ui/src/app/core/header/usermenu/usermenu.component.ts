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
import { FormControl, Validators, FormGroup } from '@angular/forms';

@Component({
  selector: 'tb-ec-usermenu',
  templateUrl: './usermenu.component.html',
  styleUrls: ['./usermenu.component.scss'],
  exportAs: ''
})
export class UsermenuComponent implements OnInit {

  constructor() {}

  public avatar = 'https://mdbootstrap.com/img/Photos/Avatars/avatar-2.jpg';
  public dotVerticalMenu = faEllipsisV;

  public signInForm: FormGroup;

  // example login form - not the finished implementation (not protected)
  signIn() {
        // TODO: Implementation
  }

  createSignInForm() {
    this.signInForm = new FormGroup({
        login: new FormControl('', [Validators.required]),
        password: new FormControl('', [Validators.required]),
    });
  }

  ngOnInit() {
    this.createSignInForm();
  }
}
