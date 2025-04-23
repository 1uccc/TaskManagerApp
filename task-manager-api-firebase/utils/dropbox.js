require('dotenv').config();
const { Dropbox } = require('dropbox');

const fetch = (...args) => import('node-fetch').then(({default: fetch}) => fetch(...args));

const dbx = new Dropbox({
  accessToken: process.env.DROPBOX_ACCESS_TOKEN,
  fetch,
});

module.exports = dbx;
