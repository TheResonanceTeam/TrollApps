<p align="center">
    <img src="../../assets/ResonanceStoreIcon.png" alt="Logo" width="70" height="70"></img>
</p>


<h1 align="center">TrollApps Documentation</h1>
<h6 align="center">This page contains information about TrollApps sources and our URL scheme.</h6>

#

### Getting Started:

For both users and repo managers, ensure the following criteria are met:

* You are running the **latest version** of TrollStore
* You are running the **latest version** of TrollApps (see the <a href="https://github.com/TheResonanceTeam/TrollApps/releases">releases page</a>)
* You have **TrollStore's URL Scheme** enabled.

<p align="center">
    <img src="https://raw.githubusercontent.com/TheResonanceTeam/TrollApps/main/assets/Docs/img/TS_URL_Scheme.jpeg" alt="TrollStore URL Scheme" width="420" height="auto"></img>
<p>

#

### TrollApps' URL Scheme

TrollApps uses the following URL Scheme for adding repos:

* `trollapps://add?url=<REPO_URL>`

You can add a button to your website that adds your repo to TrollApps automatically by having its href attribute lead to that URL scheme. For example:

* `<a href=trollapps://add?url=alt.getutm.app>Add Repo</a>`

For additional examples, you can check out the trusted sources page on <a href="https://theresonanceteam.github.io/trusted-sources">our website</a>.

#

### TrollApps Source Structure

TrollApps utilizes a json structure extremely similar to AltStore, allowing for interoperability of sources between apps. However, there are a few minor differences to note.

* Instead of using the `"screenshots": []` tag, we use `"screenshotURLs": []`, some AltStore repos utilize both, but some don't. 

* TrollApps does not currently use any information inside of `"appPermissions": {}`, so, if you are making a source specifically for TrollApps and not AltStore, you can leave this part blank.

* `"featuredApps": []` is completely optional, this is just an array of bundle ID's from your repo to be featured. 

* `"news": []` is (currently) unused.

* `"tintColor": <HEX>` is also (currently) unused.

See <a href="https://raw.githubusercontent.com/TheResonanceTeam/TrollApps/main/assets/Docs/repo_template.json">here</a> for a basic source template.