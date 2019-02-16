# -*- coding: utf-8 -*-

"""Test supported configurations of zigzag."""

# ======================================================================================================================
# Imports
# ======================================================================================================================
import uuid
import pytest


# ======================================================================================================================
# Test Suites
# ======================================================================================================================
class TestConfig(object):
    # noinspection PyUnresolvedReferences
    def test_publish_single_passing_custom_mod_hierarchy(self, single_passing_test_with_custom_mod_hierarchy):
        """Verify ZigZag can publish results from the "asc" CI environment with one passing test in the JUnitXML
        file.
        """

        # Setup
        single_passing_test_with_custom_mod_hierarchy.assert_invoke_zigzag()
        test_runs = single_passing_test_with_custom_mod_hierarchy.tests[0].qtest_test_runs

        # Expectations
        test_run_status_exp = 'Passed'

        # Test
        assert len(test_runs) == 1
        pytest.helpers.assert_qtest_property(test_runs[0], 'Status', test_run_status_exp)
        import pdb;pdb.set_trace()
        pytest.helpers.assert_qtest_property(test_runs[0], 'Status', test_run_status_exp)
