import React, { useState, Fragment } from 'react';
import searchIcon from 'images/stolen/search';
import Loading from './Loading';
import { fetchSerialResults } from '../api';

const MultiSerialSearch = () => {
  const [serialResults, setSerialResults] = useState([]);
  const [searchTokens, setSearchTokens] = useState(null);
  const [visibility, setVisibility] = useState(false);
  const [loading, setLoading] = useState(false);

  const onSearchSerials = async e => {
    e.preventDefault();
    if (!searchTokens) return;
    setLoading(true);
    const tokens = searchTokens.split(/,|\n/);
    const uniqSerials = [...new Set(tokens)];

    /* parallel request all serials */
    const all = await Promise.all(
      uniqSerials.map(serial => fetchSerialResults(serial))
    );
    const results = all.map(({ bikes }, index) => (
      {
        bikes,
        serial: uniqSerials[index],
      }
    ));
    setSerialResults(results);
    setLoading(false);
  };

  const toggleVisibility = e => {
    e.preventDefault();
    setVisibility(!visibility);
  };

  const onChangeSearchTokens = e => {
    e.preventDefault();
    const tokens = e.target.value;
    setSearchTokens(tokens);
  };

  return (
    <Fragment>
      <h4 className="multi-search-toggle">
        <a href="" onClick={toggleVisibility}>
          {visibility ? 'Hide' : 'Show'} Multiple Serial Search
        </a>
      </h4>
      {visibility && (
        loading ? <Loading /> : (
          <div className="multiserial-form">
            <span className="padded" />
            <h3>Multiple Serial Search</h3>
            <textarea
              value={searchTokens}
              className="form-control"
              onChange={onChangeSearchTokens}
              placeholder="Enter multiple serial numbers. Separate them with commas or new lines"
            />
            <button
              type="submit"
              className="sbrbtn"
              onClick={onSearchSerials}
            >
              <img alt="search" src={searchIcon} />
            </button>

            <section id="ms_search_section">
              <span className="padded" />
              <div className="multiserial-response">
                <h2>
                  Multi serial search results
                </h2>

                <ul id="serials_submitted" className="multiserials-list">
                  {serialResults.map(({ serial, results }) => (
                    <li
                      key={serial}
                      className={!results && 'ms-nomatch'}
                      name={serial}
                    >
                      {serial}
                    </li>
                  ))}
                </ul>
              </div>
            </section>
          </div>
        ))}
    </Fragment>
  );
};

export default MultiSerialSearch;


/*
  TODO:
    - append li results for each serial
      - #ms_search_section
      - #serials_submitted append if > 1 serial
    - no match with 'ms-nomatch'
    - add close matching serials
    - ensure li achors work as expected
    - loading state for close matching serials
    - fix search button style
    - replace jQuery animations
    -

*/
