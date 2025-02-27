// https://dart.dev/guides/language/effective-dart/style#prefer-using-lowercamelcase-for-constant-names
// Global APP - specific constants
const appLogoSvgPath = 'assets/app_logo/logo.svg';
const appTitle = 'Odoo Timesheets';

///This endpoint provides meta-calls which don’t require authentication.
const commonEndpoint = 'xmlrpc/2/common';

///It is used to call methods of odoo models. Require authentication.
const objectEndpoint = 'xmlrpc/2/object';

const rpcFunction = 'execute_kw';
const rpcAuthenticationFunction = 'authenticate';

const projectModel = 'project.project';
const taskModel = 'project.task';
const usersModel = 'res.users';
const timesheetEntryModel = 'account.analytic.line';


const emailControlName = 'email';
const passControlName = 'pass';
const serverUrlControlName = 'serverUrl';
const dbControlName = 'db';
