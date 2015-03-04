<%! from util import (activity_split, put_and, md_italic, split_camelcase_s, canonical_type_name, 
                      rust_test_fn_invisible, rust_doc_test_norun, rust_doc_comment, markdown_rust_block,
                      unindent, indent)  %>\
<%namespace name="util" file="util.mako"/>\

## If rust-doc is True, examples will be made to work for rust doc tests. Otherwise they are set 
## for github markdown.
<%def name="docs(c, rust_doc=True)" filter="unindent">\
<%
    # fr == fattest resource, the fatter, the more important, right ?
    fr = None
    fr = sorted(schemas.values(), key=lambda s: (len(c.sta_map.get(s.id, [])), len(s.get('properties', []))), reverse=True)[0]

    # resouce -> [activity, ...]
    amap = dict()
    for an in c.fqan_map:
        resource, activity = activity_split(an)
        amap.setdefault(resource, list()).append(activity)
%>\
    # Features

    Handle the following *Resources* with ease ... 

    % for r in sorted(amap.keys()):
    * ${split_camelcase_s(r)} (${put_and(md_italic(sorted(amap[r])))})
    % endfor

    # Structure of this Library

    The API is structured into the following primary items:

    * **Hub**
        * a central object to maintain state and allow accessing all *Activities*
    * **Resources**
        * primary types that you can apply *Activities* to
        * a collection of properties and *Parts*
        * **Parts**
            * a collection of properties
            * never directly used in *Activities*
    * **Activities**
        * operations to apply to *Resources*

    Generally speaking, you can invoke *Activities* like this:

    ```Rust,ignore
    let r = hub.resource().activity(...).${api.terms.action}()
    ```

    Or specifically ...

    ```ignore
% for an, a in c.sta_map[fr.id].iteritems():
<% resource, activity = activity_split(an) %>\
    let r = hub.${resource}().${activity}(...).${api.terms.action}()
% endfor
    ```

    The `resource()` and `activity(...)` calls create [builders][builder-pattern]. The second one dealing with `Activities` 
    supports various methods to configure the impending operation (not shown here). It is made such that all required arguments have to be 
    specified right away (i.e. `(...)`), whereas all optional ones can be [build up][builder-pattern] as desired.
    The `${api.terms.action}()` method performs the actual communication with the server and returns the respective result.

    # Usage (*TODO*)

    ${'##'} Instantiating the Hub

${self.hub_usage_example(rust_doc) | indent}\

    **TODO** Example calls - there should soon be a generator able to do that with proper inputs
    ${'##'} About error handling

    ${'##'} About Customization/Callbacks

    [builder-pattern]: http://en.wikipedia.org/wiki/Builder_pattern
    [google-go-api]: https://github.com/google/google-api-go-client
</%def>

## Sets up a hub ready for use. You must wrap it into a test function for it to work
## Needs test_prelude.
<%def name="test_hub(hub_type)" filter="unindent">\
    use oauth2::{Authenticator, DefaultAuthenticatorDelegate, ApplicationSecret, MemoryStorage};
    use std::default::Default;

    use ${util.library_name()}::${hub_type};

    // Get an ApplicationSecret instance by some means. It contains the `client_id` and `client_secret`, 
    // among other things.
    let secret: ApplicationSecret = Default::default();
    // Instantiate the authenticator. It will choose a suitable authentication flow for you, 
    // unless you replace  `None` with the desired Flow
    // Provide your own `AuthenticatorDelegate` to adjust the way it operates and get feedback about what's going on
    // You probably want to bring in your own `TokenStorage` to persist tokens and retrieve them from storage.
    let auth = Authenticator::new(&secret, DefaultAuthenticatorDelegate,
                                      hyper::Client::new(),
                                      <MemoryStorage as Default>::default(), None);
    let mut hub = ${hub_type}::new(hyper::Client::new(), auth);\
</%def>

## You will still have to set the filter for your comment type - either nothing, or rust_doc_comment !
<%def name="hub_usage_example(rust_doc=True)">\
<% 
    test_filter = rust_test_fn_invisible
    main_filter = rust_doc_test_norun
    if not rust_doc:
        test_filter = lambda s: s
        main_filter = markdown_rust_block
%>\
<%block filter="main_filter">\
${util.test_prelude()}\

<%block filter="test_filter">\
${self.test_hub(canonical_type_name(canonicalName))}\
</%block>
</%block>
</%def>

<%def name="license()" filter="unindent">\
    # License
    The **${util.library_name()}** library was generated by ${put_and(copyright.authors)}, and is placed 
    under the *${copyright.license_abbrev}* license.
    You can read the full text at the repository's [license file][repo-license].

    [repo-license]: ${cargo.repo_base_url + 'LICENSE.md'}
</%def>