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

  const express = require('express');
  const cors = require('cors');
  const activators = require('./data/activators').activators;
  const deployments = require('./data/deployments').deployments;
  const app = express();
  const port = 3000;

  const findDeploymentById = (objId, callback) => {
    if(!deployment[objId])
      return callback(new Error(
        'No deployment matching '
        + objId
        )
      );

      return callback(null, deployment[objId]);
  }

  app.use(express.urlencoded());
  app.use(express.json()) 
  app.use(express.urlencoded({extended: false}))
  app.use(cors()) // TODO: Restrict resource sharing policy when stated

  app.post("/api/build", (req, res) => {
    setTimeout(() => {
      res.sendStatus(200);
    }, 15000);
  });
  
  app.get("/api/activators", (req, res) => {
    return res.json(activators);
  });
  
  app.get("/api/activators/:id", (req, res) => {
    // To prevent the ID "0" we'll simply subtract by one. This way we can query for id = 2 which will serve us 1, etc.
    const idx = req.params.id - 1;
    
    if (!activators[idx]) {
      
      return res.status(404).json({ error: "Activator not found" });
    }
  
    return res.json(activators[idx]);
  });

  app.get("/api/deployments", (req, res) => {
    return res.json(deployments);
  });
  
  app.get("/api/deployments/:id", (req, res) => {
    const idx = req.params.id - 1;
    
    if (!deployments[idx]) {
      
      return res.status(404).json({ error: "Deployment not found" });
    }
  
    return res.json(deployments[idx]);
  });

  app.listen(port, () => {
    console.log("Server running on port " + port);
  });