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

import { Component, OnInit, ViewChild } from '@angular/core';
import { faSearch } from '@fortawesome/free-solid-svg-icons';
import { FormControl, FormGroup } from '@angular/forms';

@Component({
  selector: 'tb-ssp-search',
  templateUrl: './search.component.html',
  styleUrls: ['./search.component.scss']
})
export class SearchComponent {

    public openedSearch = false;
    searchForm = new FormGroup({
      searchInput: new FormControl('')
    });

    // @ViewChild('searchBlock') searchBlock;
    @ViewChild('searchInput') searchInput;
    @ViewChild('searchBtn') searchBtn;

    faSearch = faSearch;


    toggleSearch(e) {
      if (this.searchInputLength(this.searchInput) === 0) {
        e.preventDefault();
      }

      this.openedSearch = !this.openedSearch;

      if (this.openedSearch) {
          this.searchInput.nativeElement.classList.add('showSearch');
        } else {
          this.searchInput.nativeElement.classList.remove('showSearch');
        }
      }

      searchInputLength(searchInput) {
        const length = searchInput.value.length;
        return length;
      }
}
